class_name CircuitSimulator extends Node2D

# Core Settings
@export var simulation_fps := 60
@export var max_nonlinear_iterations := 20
@export var nonlinear_tolerance := 1e-6

# Matrix Math Helper
class SparseMatrix_cb:
	var data := {}
	var size := Vector2i.ZERO

	func _init(rows: int, cols: int):
		size = Vector2i(rows, cols)

	func set_value(row: int, col: int, value: float):
		if not data.has(row):
			data[row] = {}
		data[row][col] = value

	func add_value(row: int, col: int, value: float):
		if not data.has(row):
			data[row] = {}
		data[row][col] = data[row].get(col, 0.0) + value

	func get_value(row: int, col: int) -> float:
		return data.get(row, {}).get(col, 0.0)

# Circuit Elements
class NetNode:
	var id: int
	var position: Vector2
	var voltage := 0.0
	var is_ground := false

	func _init(pos: Vector2, node_id: int):
		position = pos
		id = node_id

class Component:
	enum Type {RESISTOR, CAPACITOR, INDUCTOR, VOLTAGE_SOURCE, CURRENT_SOURCE, DIODE}

	var id: int
	var type: Type
	var nodes: Array[NetNode] = []
	var value := 0.0
	var current := 0.0

	func _init(comp_id: int, comp_type: Type, netnodes: Array[NetNode], val: float):
		id = comp_id
		type = comp_type
		nodes = netnodes
		value = val

# Main Simulator Class
class Circuit:
	var nodes: Array[NetNode] = []
	var components: Array[Component] = []
	var ground: NetNode
	var time_step := 1.0 / 60.0
	var sparse_matrix: SparseMatrix_cb
	var rhs_vector: Array[float] = []
	var solution: Array[float] = []
	var dirty := true

	func _init():
		ground = NetNode.new(Vector2.ZERO, 0)
		ground.is_ground = true
		nodes.append(ground)

	func add_node(pos: Vector2) -> NetNode:
		var new_node = NetNode.new(pos, nodes.size())
		nodes.append(new_node)
		dirty = true
		return new_node

	func add_component(type: Component.Type, node1: NetNode, node2: NetNode, value: float) -> Component:
		var new_comp = Component.new(components.size(), type, [node1, node2], value)
		components.append(new_comp)
		dirty = true
		return new_comp

	func solve_dc():
		if not dirty:
			return

		var num_nodes = nodes.size()
		sparse_matrix = SparseMatrix_cb.new(num_nodes, num_nodes)
		rhs_vector.resize(num_nodes)
		rhs_vector.fill(0.0)

		# Build matrix
		for comp in components:
			var n1 = comp.nodes[0].id
			var n2 = comp.nodes[1].id

			match comp.type:
				Component.Type.RESISTOR:
					var g = 1.0 / comp.value
					sparse_matrix.add_value(n1, n1, g)
					sparse_matrix.add_value(n2, n2, g)
					sparse_matrix.add_value(n1, n2, -g)
					sparse_matrix.add_value(n2, n1, -g)

				Component.Type.VOLTAGE_SOURCE:
					# Modified Nodal Analysis
					var branch_eq = components.size() + n1
					sparse_matrix.add_value(n1, branch_eq, 1.0)
					sparse_matrix.add_value(n2, branch_eq, -1.0)
					sparse_matrix.add_value(branch_eq, n1, 1.0)
					sparse_matrix.add_value(branch_eq, n2, -1.0)
					rhs_vector[branch_eq] = comp.value

		# Ground node
		sparse_matrix.set_value(0, 0, 1.0)
		rhs_vector[0] = 0.0

		# Solve (using simple Gaussian elimination - replace with better solver)
		_solve_linear_system()

		# Update node voltages
		for i in num_nodes:
			nodes[i].voltage = solution[i]

		dirty = false

	func step_transient(delta: float):
		time_step = delta
		var num_nodes = nodes.size()

		# Update companion models for dynamic components
		for comp in components:
			match comp.type:
				Component.Type.CAPACITOR:
					# Backward Euler companion model
					var geq = comp.value / time_step
					var ieq = geq * (comp.nodes[0].voltage - comp.nodes[1].voltage)

					# Stamp into matrix
					sparse_matrix.add_value(comp.nodes[0].id, comp.nodes[0].id, geq)
					sparse_matrix.add_value(comp.nodes[1].id, comp.nodes[1].id, geq)
					sparse_matrix.add_value(comp.nodes[0].id, comp.nodes[1].id, -geq)
					sparse_matrix.add_value(comp.nodes[1].id, comp.nodes[0].id, -geq)
					rhs_vector[comp.nodes[0].id] += ieq
					rhs_vector[comp.nodes[1].id] -= ieq

				Component.Type.INDUCTOR:
					# Similar treatment for inductors
					pass

		solve_dc()

	func _solve_linear_system():
		# Placeholder - replace with real solver
		solution.resize(rhs_vector.size())
		solution.fill(0.0)
		solution[0] = 0.0  # Ground

# Godot Node Implementation
var circuit := Circuit.new()
var sim_time := 0.0
var draw_components := true

func _ready():
	# Clear the default circuit
	circuit = Circuit.new()

	# Create your custom circuit
	var node1 = circuit.add_node(Vector2(100, 100))
	var node2 = circuit.add_node(Vector2(300, 100))
	var node3 = circuit.add_node(Vector2(500, 100))

	# Add components (type, node1, node2, value)
	circuit.add_component(Component.Type.VOLTAGE_SOURCE, circuit.ground, node1, 9.0) # 9V battery
	circuit.add_component(Component.Type.RESISTOR, node1, node2, 1000.0) # 1kΩ resistor
	circuit.add_component(Component.Type.RESISTOR, node2, circuit.ground, 2000.0) # 2kΩ resistor
	#circuit.add_component(Component.Type.RESISTOR, node3, circuit.ground, 3000.0) # 3kΩ resistor

func _physics_process(delta: float):
	sim_time += delta
	var sim_delta = 1.0 / simulation_fps

	while sim_time >= sim_delta:
		circuit.step_transient(sim_delta)
		sim_time -= sim_delta

	queue_redraw()

func _draw():
	if not draw_components:
		return

	# Draw nodes
	for node in circuit.nodes:
		var color = Color.RED if node.is_ground else Color.WHITE
		draw_circle(node.position, 5, color)
		draw_string(ThemeDB.fallback_font, node.position + Vector2(10, -10), "%.2fV" % node.voltage)

	# Draw components
	for comp in circuit.components:
		var start = comp.nodes[0].position
		var end = comp.nodes[1].position
		var color = Color.GREEN

		match comp.type:
			Component.Type.RESISTOR:
				color = Color(0.8, 0.8, 0.2)
			Component.Type.VOLTAGE_SOURCE:
				color = Color(0.2, 0.8, 0.8)

		draw_line(start, end, color, 2)
		draw_string(ThemeDB.fallback_font, (start + end) / 2, _get_component_label(comp))

func _get_component_label(comp: Component) -> String:
	match comp.type:
		Component.Type.RESISTOR:
			return "R: %.1fΩ" % comp.value
		Component.Type.VOLTAGE_SOURCE:
			return "V: %.1fV" % comp.value
		_:
			return ""
