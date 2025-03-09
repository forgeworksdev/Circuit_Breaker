class_name CircuitSim_cb extends Node2D

const SNAP_DISTANCE: int = 50

class Wire:
	var input_netnode: NetNode
	var output_netnode: NetNode
	var color: Color

	func _init(output_netnode: NetNode, input_netnode: NetNode, color: Color) -> void:
		self.output_netnode = output_netnode
		self.input_netnode = input_netnode
		self.color = color

class Component:
	var type: String
	var value: float
	var input_netnode: NetNode
	var output_netnode: NetNode

	func _init(input_netnode: NetNode, output_netnode: NetNode, type: String, value: float) -> void:
		self.input_netnode = input_netnode
		self.output_netnode = output_netnode
		self.value = value
		self.type = type
		update_connected_nodes()

	# Automatically add this component to the connected_objects of its netnodes
	func update_connected_nodes():
		input_netnode.connected_objects.append(self)
		output_netnode.connected_objects.append(self)

class NetNode:
	var id: int
	var pos: Vector2
	var connected_objects: Array

	func _init(id: int, pos: Vector2) -> void:
		self.id = id
		self.pos = pos

class Netlist:
	var next_netnode_id: int = 1 # 0 is reserved for ground, -1 is null.
	var netnodes: Array[NetNode] = []
	var components: Array = []
	var wires: Array = []

	func add_component(component: Component):
		components.append(component)

	func add_wire(wire: Wire):
		wires.append(wire)

	func create_netnode(netnode: NetNode):
		netnodes.append(netnode)

	func get_netnode_id(netnode: NetNode):
		return netnode.id

	func get_netnode_ref(id: int):
		for netnode in netnodes:
			if netnode.id == id:
				return netnode
		print("Failed to get netnode from ID %d" % id)
		return -1

	func delete_component(component: Component):
		# Remove the component from its connected netnodes
		component.input_netnode.connected_objects.erase(component)
		component.output_netnode.connected_objects.erase(component)
		# Remove the component from the components array
		components.erase(component)

	func delete_wire(wire: Wire):
		# Remove the wire from its connected netnodes
		wire.input_netnode.connected_objects.erase(wire)
		wire.output_netnode.connected_objects.erase(wire)
		# Remove the wire from the wires array
		wires.erase(wire)

	func delete_netnode(netnode: NetNode):
		# Delete all components and wires connected to the netnode
		for obj in netnode.connected_objects:
			if obj is Component:
				delete_component(obj)
			elif obj is Wire:
				delete_wire(obj)
		# Remove the netnode from the netnodes array
		netnodes.erase(netnode)

	func find_nearby_netnodes(pos: Vector2):
		for netnode in netnodes:
			if pos.distance_to(netnode.pos) <= SNAP_DISTANCE:
				return netnode
		return null

	func merge_netnodes(netnode1: NetNode, netnode2: NetNode, new_pos: Vector2):
		# Move all connections from netnode1 to netnode2
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
		# Update netnode2's position
		netnode2.pos = new_pos
		# Remove netnode1 from the netnodes array
		netnodes.erase(netnode1)

	func find_or_create_netnode(pos: Vector2):
		# Check if a netnode exists within SNAP_DISTANCE
		for netnode in netnodes:
			if pos.distance_to(netnode.pos) <= SNAP_DISTANCE:
				return netnode
		# Create a new netnode
		var new_netnode = NetNode.new(next_netnode_id, pos)
		netnodes.append(new_netnode)
		next_netnode_id += 1
		return new_netnode

	func clear_netlist():
		components.clear()
		wires.clear()
		netnodes.clear()

	func print_netlist():
		print("Netlist:")
		for component in components:
			print("Component: %s (%d, %d)" % [component.type, component.input_netnode.id, component.output_netnode.id])
		print("Wires:")
		for wire in wires:
			print("Wire: (%d, %d) -> Color: %s" % [wire.input_netnode.id, wire.output_netnode.id, str(wire.color)])

	func export_netlist(file_path: String):
		var data = {
			"netnodes": [],
			"components": [],
			"wires": []
		}
		for netnode in netnodes:
			data["netnodes"].append({
				"Id": netnode.id,
				"Position": netnode.pos
			})
		for component in components:
			data["components"].append({
				"type": component.type,
				"value": component.value,
				"input_netnode": component.input_netnode.id,
				"output_netnode": component.output_netnode.id
			})
		for wire in wires:
			data["wires"].append({
				"input_netnode": wire.input_netnode.id,
				"output_netnode": wire.output_netnode.id,
				"color": wire.color
			})

		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(data, "\t"))
			print("Netlist exported to %s :D" % file_path)
		else:
			print("Failed to open file for writing :c (Circuit.gd)")

	func _init(pos: Vector2):
		create_netnode(NetNode.new(0, pos))

var netlist: Netlist = Netlist.new(Vector2(50, 50))

var is_placing
var placement_start

func place_component(pos: Vector2 = Vector2(0, 0), type: String = "Resistor_cb"):
	if is_placing:
		var pos2 = pos
		var netnode1 = netlist.find_or_create_netnode(placement_start)
		var netnode2 = netlist.find_or_create_netnode(pos2)
		netlist.add_component(Component.new(netnode1, netnode2, type, 100.0))
		is_placing = false
		netlist.print_netlist() #DEBUG
	else:
		placement_start = pos
		is_placing = true
	queue_redraw()

func place_wire(pos: Vector2 = Vector2(0, 0), color: Color = Color.BLUE):
	if is_placing:
		var pos2 = pos
		var netnode1 = netlist.find_or_create_netnode(placement_start)
		var netnode2 = netlist.find_or_create_netnode(pos2)
		netnode2.id = netnode1.id
		netlist.add_wire(Wire.new(netnode1, netnode2, color))
		is_placing = false
		netlist.print_netlist() #DEBUG
	else:
		placement_start = pos
		is_placing = true
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_component(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			place_wire(event.position)

func _draw() -> void:
	for netnode in netlist.netnodes:
		draw_circle(netnode.pos, 5, Color.WHITE if netnode.id != 0 else Color.YELLOW)
		draw_string(Corec.native_font, netnode.pos + Vector2(10, -10), str(netnode.id))

	for component in netlist.components:
		var pos1 = component.input_netnode.pos
		var pos2 = component.output_netnode.pos
		draw_line(pos1, pos2, Color.GREEN, 2)
	for wire in netlist.wires:
		var pos1 = wire.input_netnode.pos
		var pos2 = wire.output_netnode.pos
		draw_line(pos1, pos2, wire.color, 2)

func calculate_values(netlist: Netlist):
	for component in netlist["components"]:
		if component.type == "Resistor_cb":
			var voltage = netlist["netnodes"][component.netnode1] - netlist["netnodes"][component.netnode2]
			var current = voltage / component.resistance
			var power = current * voltage
			print("Resistor_cb (R = %0.2f Ω):" % component.resistance)
			print("  Voltage: %0.2f V" % voltage)
			print("  Current: %0.2f A" % current)
			print("  Power: %0.2f W" % power)
			print()

		elif component.type == "Diode_cb":
			var voltage = netlist["netnodes"][component.netnode1] - netlist["netnodes"][component.netnode2]
			if voltage >= component.forward_voltage:
				var current = 0.001  # 1 mA
				var power = component.forward_voltage * current
				print("Diode_cb (V_f = %0.2f V):" % component.forward_voltage)
				print("  Voltage: %0.2f V" % voltage)
				print("  Current: %0.2f A" % current)
				print("  Power: %0.2f W" % power)
				print()
			else:
				print("Diode_cb (V_f = %0.2f V):" % component.forward_voltage)
				print("  Voltage: %0.2f V (reverse-biased)" % voltage)
				print("  Current: 0.00 A")
				print("  Power: 0.00 W")
				print()
