extends Node2D

# Consts
const SNAP_DISTANCE = 50.0

# Data Structures
class Component:
	var type: String
	var value: float
	var netnode1: int
	var netnode2: int

	func _init(type: String, value: float, netnode1: int, netnode2: int):
		self.type = type
		self.value = value
		self.netnode1 = netnode1
		self.netnode2 = netnode2

class Wire:
	var start_point: Vector2
	var end_point: Vector2
	var netnode1: int

	func _init(start_point: Vector2, end_point: Vector2, netnode1: int):
		self.start_point = start_point
		self.end_point = end_point
		self.netnode1 = netnode1

#region Netlist class
class Netlist:
	var next_netnode_id = 1  # Node 0 is reserved for ground, -1 is reserved for null
	var netnodes = {}  # Dictionary: {netnode_id: Vector2}
	var components := []
	var wires := []

	func add_component(component: Component):
		components.append(component)

	func add_wire(wire: Wire):
		wires.append(wire)

#region Netlist "methods"
	func find_or_create_netnode(pos: Vector2) -> int: #TODO Break this one in two (find n create)
		# Check if a netnode exists within SNAP_DISTANCE
		for netnode_pos in netnodes:
			if pos.distance_to(netnodes[netnode_pos]) <= SNAP_DISTANCE:
				return netnode_pos
		# Create a new netnode
		netnodes[next_netnode_id] = pos
		next_netnode_id += 1
		return next_netnode_id - 1

	#func move_netnode(netnode_id: int, new_position: Vector2):
		## Update the netnode's position
		#netnodes[netnode_id] = new_position

	#func highlight_connections(netnode_id: int):
		#for component in components:
			#if component.netnode1 == netnode_id or component.netnode2 == netnode_id:
				#print("Connected Component: %s (%d, %d)" % [component.type, component.netnode1, component.netnode2])

	#func split_netnode(netnode_id: int, new_position: Vector2) -> int:
		## Create a new netnode at the specified position
		#var new_netnode_id = find_or_create_netnode(new_position)
		## Update components connected to the original netnode
		#for component in components:
			#if component.netnode1 == netnode_id:
				#component.netnode1 = new_netnode_id
			#if component.netnode2 == netnode_id:
				#component.netnode2 = new_netnode_id
		#return new_netnode_id

	#func merge_netnodes(netnode1: int, netnode2: int):
		## Merge netnode2 into netnode1
		#for component in components:
			#if component.netnode1 == netnode2:
				#component.netnode1 = netnode1
			#if component.netnode2 == netnode2:
				#component.netnode2 = netnode1
		#netnodes.erase(netnode2)

	#func delete_netnode(netnode_id: int):
		## Remove the netnode from the netnodes dictionary
		#netnodes.erase(netnode_id)
		## Remove all components connected to the netnode
		#components = components.filter(func(component):
			#return component.netnode1 != netnode_id and component.netnode2 != netnode_id
		#)
#
	#func delete_component(component_index: int):
		## Remove the component from the components array
		#components.remove_at(component_index)
#endregion

	func print_netlist():
		print("Netlist:")
		for component in components:
			print("Component: %s (%d, %d)" % [component.type, component.netnode1, component.netnode2])
		#print("\nWires:")
		#for wire in wires:
			#print("Wire: (%d, %d) -> %d" % [wire.start, wire.end, wire.output_netnode])

	func export_netlist(file_path: String):
		var data = {
			"components": [],
			"wires": [],
			"netnodes": netnodes
		}
		for component in components:
			data["components"].append({
				"type": component.type,
				"value": component.value,
				"netnode1": component.netnode1,
				"netnode2": component.netnode2
			})
		#for wire in wires:
			#data["wires"].append({
				#"start": {"x": wire.start.x, "y": wire.start.y},
				#"end": {"x": wire.end.x, "y": wire.end.y},
				#"output_netnode": wire.output_netnode
			#})
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(data, "\t"))
			print("Netlist exported to %s :D" % file_path)
		else:
			print("Failed to open file for writing :c (109 of Circuit.gd)")
#endregion


# Variables
var netlist = Netlist.new()

# Example Circuit
func generate_example_netlist():
	# Ground netnode (netnode 0)
	netlist.netnodes[0] = Vector2(100, 400)
	# Resistor between netnode 1 and netnode 2
	var netnode1 = netlist.find_or_create_netnode(Vector2(200, 300))
	var netnode2 = netlist.find_or_create_netnode(Vector2(300, 300))
	netlist.add_component(Component.new("resistor", 100.0, netnode1, netnode2))
	# Voltage source between netnode 0 and netnode 1
	netlist.add_component(Component.new("voltage_source", 5.0, 0, netnode1))
	netlist.print_netlist()
	netlist.export_netlist("user://netlist.json")

var is_placing: bool = false
var placement_start: Vector2 = Vector2.ZERO
func place_component(pos: Vector2 = Vector2(0,0), type: String = "Resistor_cb"):
	if is_placing:
		# When placing the component, calculate the second position
		var pos2 = pos
		var netnode1 = netlist.find_or_create_netnode(placement_start)
		var netnode2 = netlist.find_or_create_netnode(pos2)
		netlist.add_component(Component.new(type, 100.0, netnode1, netnode2))
		is_placing = false
		netlist.print_netlist() #DEBUG
		queue_redraw()
	else:
		placement_start = pos
		is_placing = true

func place_wire(pos: Vector2 = Vector2(0,0)):
	if is_placing:
		# When placing the component, calculate the second position
		var pos2 = pos
		var netnode1 = netlist.find_or_create_netnode(placement_start)
		var netnode2 = netlist.find_or_create_netnode(pos2)
		is_placing = false
		netlist.print_netlist() #DEBUG
		queue_redraw()
	else:
		placement_start = pos
		is_placing = true

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Place a resistor
			place_component(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Place a voltage source
			##place_component(event.position, "VoltageSource_cb")
			#var pos1 = event.position
			#var netnode1 = netlist.find_or_create_netnode(pos1)
			#netlist.add_component(Component.new("VoltageSource_cb", 5.0, 0, netnode1))
			queue_redraw()

# Main
func _ready():
	netlist.netnodes[0] = Vector2(100, 400)
	#generate_example_netlist()

# Visualization
func _draw():
	# Draw netnodes
	for netnode_id in netlist.netnodes:
		var position = netlist.netnodes[netnode_id]
		draw_circle(position, 5, Color.WHITE if netnode_id != 0 else Color.YELLOW)
		#Draws a string to represent the netnode number
		draw_string(Corec.native_font, position + Vector2(10, -10), str(netnode_id))
	# Draw connections
	for component in netlist.components:
		var pos1 = netlist.netnodes[component.netnode1]
		var pos2 = netlist.netnodes[component.netnode2]
		draw_line(pos1, pos2, Color.GREEN, 4)
