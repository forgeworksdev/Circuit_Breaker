class_name CircuitSim_cb_exp extends Node2D

@export var grid_size: Vector2
@export var netnode_click_area: Vector2

const SNAP_DISTANCE: int = 50
const NULL_NETNODE_ID: int = -1

enum SimulationMode { DC, AC }
var simulation_mode: SimulationMode = SimulationMode.DC

# Complex number class for AC analysis
class Complex:
	var real: float
	var imag: float

	func _init(r: float = 0, i: float = 0):
		real = r
		imag = i

	func add(c: Complex) -> Complex:
		return Complex.new(real + c.real, imag + c.imag)

	func multiply(c: Complex) -> Complex:
		return Complex.new(
			real * c.real - imag * c.imag,
			real * c.imag + imag * c.real
		)

	func reciprocal() -> Complex:
		var denom = real*real + imag*imag
		return Complex.new(real/denom, -imag/denom)

	func divide(c: Complex) -> Complex:
		return multiply(c.reciprocal())

	func magnitude() -> float:
		return sqrt(real*real + imag*imag)

	func phase() -> float:
		return atan2(imag, real)

# NetNode class
class NetNode:
	var is_selected: bool = false
	var id: int
	var pos: Vector2
	var connected_objects: Array = []
	var voltage: float = 0.0  # Node voltage for DC analysis

	func _init(id: int, pos: Vector2) -> void:
		self.id = id
		self.pos = pos

# Component class (enhanced for AC/DC)
class Component:
	var id: int
	var is_selected: bool = false
	var type: String
	var resistance: float
	var inductance: float
	var capacitance: float
	var voltage: Complex # Complex voltage for AC
	var current: Complex = Complex.new(0, 0) # Initialize current to avoid null
	var frequency: float
	var impedance: Complex
	var input_netnode: NetNode
	var output_netnode: NetNode

	func _init(input_netnode: NetNode, output_netnode: NetNode, type: String,
			voltage: Complex = Complex.new(), resistance: float = 0,
			inductance: float = 0, capacitance: float = 0) -> void:
		self.input_netnode = input_netnode
		self.output_netnode = output_netnode
		self.type = type
		self.resistance = resistance
		self.inductance = inductance
		self.capacitance = capacitance
		self.voltage = voltage
		update_impedance()

	func update_impedance(freq: float = 60.0) -> void:
		match type:
			"Resistor_cb":
				impedance = Complex.new(resistance, 0)
			"Inductor_cb":
				var ω = 2 * PI * freq
				impedance = Complex.new(0, ω * inductance)
			"Capacitor_cb":
				var ω = 2 * PI * freq
				impedance = Complex.new(0, -1 / (ω * capacitance))
			"VoltageSource_cb":
				impedance = Complex.new(0, 0)
			_:
				impedance = Complex.new(0, 0)

# Wire class
class Wire:
	var is_selected: bool = false
	var input_netnode: NetNode
	var output_netnode: NetNode
	var color: Color

	func _init(output_netnode: NetNode, input_netnode: NetNode, color: Color) -> void:
		self.output_netnode = output_netnode
		self.input_netnode = input_netnode
		self.color = color

		update_connected_nodes()

	func update_connected_nodes():
		if input_netnode and not self in input_netnode.connected_objects:
			input_netnode.connected_objects.append(self)
		if output_netnode and not self in output_netnode.connected_objects:
			output_netnode.connected_objects.append(self)

# Netlist class
class Netlist:
	var next_netnode_id: int = 1 # 0 is reserved for ground, -1 is null.
	var next_component_id: int = 1
	var netnodes: Array[NetNode] = []
	var components: Array = []
	var wires: Array = []

	func add_component(component: Component, supress_next_component_id: bool = false):
		component.id = next_component_id
		if !supress_next_component_id:
			next_component_id += 1
		components.append(component)
		return component

	func add_wire(wire: Wire):
		wires.append(wire)
		return wire

	func add_netnode(netnode: NetNode, supress_next_netnode_id: bool = false):
		if !supress_next_netnode_id:
			next_netnode_id += 1
		netnodes.append(netnode)
		return netnode

	func get_netnode_by_id(id: int):
		for netnode in netnodes:
			if netnode.id == id:
				return netnode
		print("Failed to get netnode from ID %d" % id)

	func get_component_by_id(id: int):
		for component in components:
			if component.id == id:
				return component
		print("Failed to get component from ID %d" % id)

	func delete_component(component: Component):
		if component in component.input_netnode.connected_objects:
			component.input_netnode.connected_objects.erase(component)
		if component in component.output_netnode.connected_objects:
			component.output_netnode.connected_objects.erase(component)
		if component in components:
			components.erase(component)

	func delete_wire(wire: Wire):
		if wire in wire.input_netnode.connected_objects:
			wire.input_netnode.connected_objects.erase(wire)
		if wire in wire.output_netnode.connected_objects:
			wire.output_netnode.connected_objects.erase(wire)
		wires.erase(wire)

	func delete_netnode(netnode: NetNode):
		for obj in netnode.connected_objects:
			if obj is Component:
				delete_component(obj)
			elif obj is Wire:
				delete_wire(obj)
		if netnode in netnodes:
			netnodes.erase(netnode)

	func find_nearest_netnode(pos: Vector2):
		for netnode in netnodes:
			if pos.distance_to(netnode.pos) <= SNAP_DISTANCE:
				return netnode
		return null

	func merge_netnodes(netnode1: NetNode, netnode2: NetNode, new_pos: Vector2):
		if netnode1 == netnode2:
			print("Cannot merge a netnode with itself.")
			return
		if not netnode1 or not netnode2:
			print("One or both netnodes are invalid.")
			return

		for obj in netnode1.connected_objects:
			if obj is Component:
				if obj.input_netnode == netnode1:
					obj.input_netnode = netnode2
				if obj.output_netnode == netnode1:
					obj.output_netnode = netnode2
				netnode2.connected_objects.append(obj)
			elif obj is Wire:
				if obj.input_netnode == netnode1:
					obj.input_netnode = netnode2
				if obj.output_netnode == netnode1:
					obj.output_netnode = netnode2
				netnode2.connected_objects.append(obj)
		netnode2.pos = new_pos
		netnodes.erase(netnode1)

	func find_or_create_netnode(pos: Vector2, supress_next_netnode_id: bool = false):
		if not pos:
			print("Invalid position provided.")
			return null
		if find_nearest_netnode(pos) != null:
			return find_nearest_netnode(pos)
		var new_netnode = NetNode.new(next_netnode_id, pos)
		add_netnode(new_netnode, supress_next_netnode_id)
		return new_netnode

	func clear_netlist():
		for netnode in netnodes:
			netnode.connected_objects.clear()
		components.clear()
		wires.clear()
		netnodes.clear()
		next_netnode_id = 1

	func print_netlist():
		print("Netlist:")
		for component in components:
			print("Component: %s (%d, %d), id: %d" % [component.type, component.input_netnode.id, component.output_netnode.id, component.id])
		print("Wires:")
		for wire in wires:
			print("Wire: (%d, %d) -> Color: %s" % [wire.input_netnode.id, wire.output_netnode.id, str(wire.color.to_html())])

	# DC Solver
	func solve_dc():
		var ground = get_netnode_by_id(0)
		if not ground:
			print("Ground node not found.")
			return

		var nodes = {}
		var node_index = 0
		for netnode in netnodes:
			if netnode != ground:
				nodes[netnode.id] = node_index  # Use node ID as key
				node_index += 1

		# Track voltage sources
		var voltage_sources = []
		for component in components:
			if component.type == "VoltageSource_cb":
				voltage_sources.append(component)

		# Matrix dimensions: nodes + voltage sources
		var size = nodes.size() + voltage_sources.size()
		var G = [] # Conductance matrix
		var I = [] # Current vector
		for i in size:
			G.append([])
			I.append(0.0)
			for j in size:
				G[i].append(0.0)

		# Build conductance matrix for resistors
		for component in components:
			var n1 = component.input_netnode
			var n2 = component.output_netnode

			if component.type == "Resistor_cb":
				var g = 1.0 / component.resistance
				if n1 != ground:
					G[nodes[n1.id]][nodes[n1.id]] += g
				if n2 != ground:
					G[nodes[n2.id]][nodes[n2.id]] += g
				if n1 != ground and n2 != ground:
					G[nodes[n1.id]][nodes[n2.id]] -= g
					G[nodes[n2.id]][nodes[n1.id]] -= g

		# Add voltage source equations
		for vs_idx in voltage_sources.size():
			var vs = voltage_sources[vs_idx]
			var n1 = vs.input_netnode
			var n2 = vs.output_netnode
			var vs_row = nodes.size() + vs_idx

			# Voltage equation: V_n1 - V_n2 = V_source
			if n1 != ground:
				G[vs_row][nodes[n1.id]] = 1
			if n2 != ground:
				G[vs_row][nodes[n2.id]] = -1
			G[nodes[n1.id]][vs_row] = 1  # Symmetric entry
			G[nodes[n2.id]][vs_row] = -1 # Symmetric entry

			I[vs_row] = vs.voltage.real  # Source voltage

		# Solve matrix equation
		var V = gaussian_elimination(G, I)

		# Update node voltages
		for netnode in netnodes:
			if netnode != ground:
				netnode.voltage = V[nodes[netnode.id]]

		# Update component currents
		for component in components:
			if component.type == "Resistor_cb":
				var n1 = component.input_netnode
				var n2 = component.output_netnode
				var voltage_diff = n1.voltage - n2.voltage
				component.current = Complex.new(voltage_diff / component.resistance, 0)
			elif component.type == "VoltageSource_cb":
				var vs_idx = voltage_sources.find(component)
				if vs_idx != -1:
					var current = V[nodes.size() + vs_idx]
					component.current = Complex.new(current, 0)

	# Gaussian elimination solver
	func gaussian_elimination(G: Array, I: Array) -> Array:
		var n = I.size()
		for i in n:
			# Find the row with the maximum element in the current column
			var max_row = i
			for j in range(i + 1, n):
				if abs(G[j][i]) > abs(G[max_row][i]):
					max_row = j

			# Swap the maximum row with the current row
			for j in range(i, n):
				var tmp = G[i][j]
				G[i][j] = G[max_row][j]
				G[max_row][j] = tmp
			var tmp = I[i]
			I[i] = I[max_row]
			I[max_row] = tmp

			# Make all rows below this one 0 in the current column
			for j in range(i + 1, n):
				var c = -G[j][i] / G[i][i]
				for k in range(i, n):
					if i == k:
						G[j][k] = 0
					else:
						G[j][k] += c * G[i][k]
				I[j] += c * I[i]

		# Back substitution
		var V = []
		V.resize(n)
		for i in range(n - 1, -1, -1):
			V[i] = I[i] / G[i][i]
			for j in range(i - 1, -1, -1):
				I[j] -= G[j][i] * V[i]
		return V

	# AC Solver (placeholder)
	func solve_ac():
		print("AC solver not yet implemented.")

	func _init(pos: Vector2):
		add_netnode(NetNode.new(0, pos), true)

var netlist: Netlist = Netlist.new(Vector2(50, 50))
var is_placing: bool = false
var placement_start: Vector2
var netnode1: NetNode
var netnode2: NetNode

# Component placement
func place_component(pos: Vector2 = Vector2(0, 0), type: String = "Resistor_cb"):
	if is_placing:
		var pos2 = pos
		netnode2 = netlist.find_or_create_netnode(pos2.snapped(grid_size))
		netlist.add_component(Component.new(netnode1, netnode2, type))
		is_placing = false
		netlist.print_netlist() #DEBUG
	else:
		placement_start = pos
		netnode1 = netlist.find_or_create_netnode(placement_start.snapped(grid_size))
		is_placing = true
	queue_redraw()

# Wire placement
func place_wire(pos: Vector2 = Vector2(0, 0), color: Color = Color.BLUE):
	if is_placing:
		var pos2 = pos
		netnode2 = netlist.find_or_create_netnode(pos2.snapped(grid_size), true)
		netnode2.id = netnode1.id
		netlist.add_wire(Wire.new(netnode1, netnode2, color))
		is_placing = false
		netlist.print_netlist() #DEBUG
	else:
		placement_start = pos
		netnode1 = netlist.find_or_create_netnode(placement_start.snapped(grid_size))
		is_placing = true
	queue_redraw()

# Input handling
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_component(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			place_wire(event.position)

# Drawing
func _draw() -> void:
	# Draw netnodes
	for netnode in netlist.netnodes:
		draw_circle(netnode.pos, 5, Color.WHITE if netnode.id != 0 else Color.YELLOW)
		draw_string(Corec.native_font, netnode.pos + Vector2(10, -10), str(netnode.id))

	# Draw components
	for component in netlist.components:
		# Skip components with invalid nodes
		if not component.input_netnode or not component.output_netnode:
			continue

		var pos1 = component.input_netnode.pos
		var pos2 = component.output_netnode.pos
		draw_line(pos1, pos2, Color.GREEN, 4)

	# Draw wires
	for wire in netlist.wires:
		# Skip wires with invalid nodes
		if not wire.input_netnode or not wire.output_netnode:
			continue

		var pos1 = wire.input_netnode.pos
		var pos2 = wire.output_netnode.pos
		draw_line(pos1, pos2, wire.color, 4)

# Simulation loop
#func _process(delta: float) -> void:
	#match simulation_mode:
		#SimulationMode.DC:
			#netlist.solve_dc()
		#SimulationMode.AC:
			#netlist.solve_ac()
	queue_redraw()

func _ready() -> void:
	generate_and_solve_example_netlist()
func generate_and_solve_example_netlist():
	# Clear any existing netlist
	netlist.clear_netlist()
	netlist.add_netnode(NetNode.new(0, Vector2(50, 50)), true)

	# Create nodes
	var ground = netlist.get_netnode_by_id(0)  # Ground node (ID 0)
	var node1 = netlist.find_or_create_netnode(Vector2(100, 100))  # Node 1
	var node2 = netlist.find_or_create_netnode(Vector2(200, 100))  # Node 2

	# Add a 10V voltage source between ground and node1
	var voltage_source = Component.new(ground, node1, "VoltageSource_cb", Complex.new(10, 0))
	netlist.add_component(voltage_source)

	# Add a 100Ω resistor between node1 and node2
	var resistor1 = Component.new(node1, node2, "Resistor_cb", Complex.new(), 100.0)
	netlist.add_component(resistor1)

	# Add a 200Ω resistor between node2 and ground
	var resistor2 = Component.new(node2, ground, "Resistor_cb", Complex.new(), 200.0)
	netlist.add_component(resistor2)

	# Solve the DC circuit
	netlist.solve_dc()

	# Print the results
	print("=== Simulation Results ===")
	print("Ground Node Voltage: 0 V (reference)")
	print("Node 1 Voltage: ", node1.voltage, " V")
	print("Node 2 Voltage: ", node2.voltage, " V")
	print("Resistor 1 Current: ", resistor1.current.real, " A")
	print("Resistor 2 Current: ", resistor2.current.real, " A")
