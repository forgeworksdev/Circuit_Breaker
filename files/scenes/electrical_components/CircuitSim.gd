class_name CircuitSim_cb extends Node2D

# github.com/forgeworksdev
#
#         :XXXXo;'                .;lXXXXl
#         cNX....                  ....KNo
#         ,do                          ld;
#         ...    .cccccc:  ;cccccc.    ...
#                ,NNxx0N0  kNKxxNN:
#                'KK. cKk  xKo  KK;
#                .::  .:;  ,:'  ::.
#              ,::::  .::::::'  ::::;
#
#              cxc  ',. .xx. .,,  :xo
#         .'.  ,:,  ...  ::.  ..  ':;  .'.
#         ,xd                          lx;
#         cNX''..                  ..''KNo
#         :KKKKl;'                .;cKKKKc

# ForgeWorks
#
# In engineering I trust.
#Na engenharia confio.
#
#licensed under the
#Sob a
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#
#This is a...
#
#Circuit Simulator
#
#Isso é um(a).....
#
#Simulador de Circuito

@export var grid_size: Vector2
@export var netnode_click_area: Vector2

const SNAP_DISTANCE: int = 50

class CircuitElement:
	var idgen = Corec.IDGenerator.new()
	var id: int
	var uuid: String = idgen.generate_uuid()
	var display_name: String

	#func _init():
		#self.uuid =

enum ComponentTypes {
	BASE,
	RESISTOR,
	CAPACITOR,
	TRANSFORMER,
	DIODE,
	LED,
	BREAKER,
	SOURCE
}

class NetNode extends CircuitElement:
	var is_selected: bool = false
	var pos: Vector2
	var connected_objects: Array = []

	func _init(netnode_position: Vector2, netnode_id: int = -1) -> void:
		self.id = netnode_id
		self.pos = netnode_position

class Component extends CircuitElement:
	var is_selected: bool = false
	var type: ComponentTypes = ComponentTypes.BASE
	var voltage: float
	var current: float
	var power:float
	var terminal_netnodes: Array[NetNode] = []

	func _init(input_netnode: NetNode, output_netnode: NetNode, component_type: ComponentTypes, voltage: float = 0, current: float = 0, power: float = 0, component_id:int = -1) -> void:
		self.id = component_id
		self.terminal_netnodes.append(input_netnode)
		self.terminal_netnodes.append(output_netnode)
		self.type = component_type

		update_connected_netnodes()

	func update_connected_netnodes():
		if terminal_netnodes[0] and not self in terminal_netnodes[0].connected_objects:
			terminal_netnodes[0].connected_objects.append(self)
		if terminal_netnodes[1] and not self in terminal_netnodes[0].connected_objects:
			terminal_netnodes[0].connected_objects.append(self)

class ResistorComponent extends Component:
	var resistance: float

class Wire extends CircuitElement:
	var is_selected: bool = false
	var terminal_netnodes: Array[NetNode] = []
	var color: Color

	func _init(output_netnode: NetNode, input_netnode: NetNode, wire_color: Color, wire_id: int = -1) -> void:
		self.id = wire_id
		if output_netnode:
			self.terminal_netnodes.append(input_netnode)
		if input_netnode:
			self.terminal_netnodes.append(output_netnode)
		self.color = wire_color

		update_connected_netnodes()

	func update_connected_netnodes():
		if terminal_netnodes[0] and not self in terminal_netnodes[0].connected_objects:
			terminal_netnodes[0].connected_objects.append(self)
		if terminal_netnodes[1] and not self in terminal_netnodes[1].connected_objects:
			terminal_netnodes[1].connected_objects.append(self)

class Netlist:
	#var next_netnode_id: int = 0 # 0 is reserved for ground.
	#var next_component_id: int = 1
	#var next_wire_id: int = 1
	var IDGenerator = Corec.IDGenerator.new()
	var IDGenerator_comps = Corec.IDGenerator.new()
	var IDGenerator_wires = Corec.IDGenerator.new()
	var netnodes: Array[NetNode] = []
	var components: Array[Component] = []
	var wires: Array[Wire] = []

	func add_component_to_netlist(component: Component, supress_next_id: bool = false):
		if supress_next_id:
			component.id = IDGenerator_comps.get_id()
		else:
			component.id = IDGenerator_comps.get_next_id()
		components.append(component)

	func add_wire_to_netlist(wire: Wire, supress_next_id: bool = false):
		if supress_next_id:
			wire.id = IDGenerator_wires.get_id()
		else:
			wire.id = IDGenerator_wires.get_next_id()
		wires.append(wire)

	func add_netnode_to_netlist(netnode: NetNode, supress_next_id: bool = false):
		if supress_next_id:
			netnode.id = IDGenerator.get_id()
		else:
			netnode.id = IDGenerator.get_next_id()
		netnodes.append(netnode)

	func get_netnode_by_id(id: int):
		for netnode in netnodes:
			if netnode.id == id:
				return netnode
		print("Failed to get netnode from ID %d" % id)
		return null

	func get_component_by_id(id: int):
		for component in components:
			if component.id == id:
				return component
		print("Failed to get component from ID %d" % id)
		return null

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

	##Deletes the NetNode along with all components and wires linked to it.
	func delete_netnode(netnode: NetNode):
		for obj in netnode.connected_objects:
			if obj is Component:
				delete_component(obj)
			elif obj is Wire:
				delete_wire(obj)
		# Remove the netnode from the netnodes array
		if netnode in netnodes:
			netnodes.erase(netnode)


	##Yeah, this is fucking DANGER, it's almost there tho
	func merge_netnodes(netnode1: NetNode, netnode2: NetNode, new_pos: Vector2):
		if netnode1 == netnode2:
			print("Cannot merge a NetNode with itself.")
			return
		if not netnode1 or not netnode2:
			print("One or both NetNodes are invalid.")
			return

		# Move all connections from netnode1 to netnode2
		var median_netnode_pos: Vector2 = Vector2((netnode1.pos.x + netnode2.pos.x)/2,(netnode1.pos.y + netnode2.pos.y)/2)
		var result_netnode = NetNode.new(median_netnode_pos, )
		add_netnode_to_netlist(result_netnode)
		#for obj in :
			#if obj is Component:
				#netnode2.connected_objects.append(obj)
			#elif obj is Wire:
				#if obj.input_netnode == netnode1:
					#obj.input_netnode = netnode2
				#if obj.output_netnode == netnode1:
					#obj.output_netnode = netnode2
				#netnode2.connected_objects.append(obj)
		## Update netnode2's position
		#netnode2.pos = new_pos
		## Remove netnode1 from the netnodes array
		#netnodes.erase(netnode1)


	func find_nearest_netnode(pos: Vector2):
		for netnode in netnodes:
			if pos.distance_to(netnode.pos) <= SNAP_DISTANCE:
				return netnode
		return null

	func find_or_create_netnode(pos: Vector2, supress_next_netnode_id: bool = false):
		# Check if a netnode exists within SNAP_DISTANCE
		var nearest_netnode = find_nearest_netnode(pos)
		if nearest_netnode != null:
			return nearest_netnode
		# Create a new netnode
		var new_netnode = NetNode.new(pos)
		add_netnode_to_netlist(new_netnode, supress_next_netnode_id)
		return new_netnode

	func clear_netlist():
		for netnode in netnodes:
			netnode.connected_objects.clear()
		components.clear()
		wires.clear()
		netnodes.clear()

	func get_type_from_index(index: int):
		match index:
			0:
				return "Base "
			1:
				return "Resistor "
			2:
				return "Capacitor "
			3:
				return "Transformer "
			4:
				return "Diode "
			5:
				return "Light Emitting Diode LED "
			6:
				return "Breaker "
			7:
				return "Source "
			_:
				"Unkown component. "

	func get_id_from_netnode_array(netnode_array: Array[NetNode]):
		var result:Array[int]
		for netnode in netnode_array:
			result.append(netnode.id)
		return result

	func print_netlist():
		print("Netlist:")
		print("	NetNodes")
		for netnode in netnodes:
			print("		Netnode UUID: %s\n 			Position.x: %f\n 			Position.y: %f" % [netnode.uuid, netnode.pos.x, netnode.pos.y])
		print("	Components:")
		for component in components:
			print("		Component UUID: %s\n			ID: %d\n			Type: %s\n			Terminal NetNodes: (%d, %d)\n" % [component.uuid, component.id, get_type_from_index(component.type) + "Type index = " + str(component.type), component.terminal_netnodes[0].id,  component.terminal_netnodes[0].id,])
		print("	Wires:")
		for wire in wires:
			print("		Wire UUID: %s\n			ID: %d\n			Terminal NetNodes: ()%d, %d)\n			Color: %s \n" % [wire.uuid, wire.id, wire.terminal_netnodes[0].id, wire.terminal_netnodes[1].id,  "#" +  str(wire.color.to_html())])

##BROKEN
	func load_netlist(file_path: String):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file:
			print("Failed to open file for reading: ", file_path)
			return

		# Parse the JSON data
		var json = JSON.new()
		var json_data = json.parse(file.get_as_text())
		if json_data != OK:
			print("Failed to parse JSON")
			return

		var data = json.get_data()

		# Clear existing data
		clear_netlist()

		# Load netnodes
		for netnode_data in data["netnodes"]:
			var netnode = NetNode.new(Vector2(netnode_data["position_x"], netnode_data["position_y"]), netnode_data["id"])
			netnodes.append(netnode)

		# Load components
		for component_data in data["components"]:
			var input_netnode = get_netnode_by_id(component_data["input_netnode"])
			var output_netnode = get_netnode_by_id(component_data["output_netnode"])
			if input_netnode and output_netnode:
				var component = Component.new(
					input_netnode,
					output_netnode,
					component_data["type"],
					component_data["voltage"],
					component_data["current"],
					component_data["power"]
				)
				add_component_to_netlist(component)
			else:
				print("Failed to find netnodes for component: ", component_data)

		# Load wires
		for wire_data in data["wires"]:
			#Both the input and output netnodes in Wire share the same id, this is why this is structured this way
			var input_netnode = add_netnode_to_netlist(NetNode.new(Vector2(wire_data["input_netnode_pos_x"],wire_data["input_netnode_pos_y"]), wire_data["shared_id"]), true)
			var output_netnode = add_netnode_to_netlist(NetNode.new(Vector2(wire_data["output_netnode_pos_x"],wire_data["output_netnode_pos_y"]), wire_data["shared_id"]), true)
			if input_netnode and output_netnode:
				var wire_color = Color(wire_data["color"])  # Reconstruct color from hexadecimal string
				var wire = Wire.new(input_netnode, output_netnode, wire_color, 0)
				add_wire_to_netlist(wire)
			else:
				print("Failed to find NetNodes for wire: ", wire_data)

		print("Netlist loaded successfully from: ", file_path)

	func export_netlist(file_path: String):
		var data = {
			"netnodes": [],
			"components": [],
			"wires": []
		}
		for netnode in netnodes:
			data["netnodes"].append({
				"id": netnode.id,
				"position_x": netnode.pos.x,
				"position_y": netnode.pos.y
			})
		for component in components:
			data["components"].append({
				"type": get_type_from_index(component.type),
				"type_index": component.type,
				"netnodes": get_id_from_netnode_array(component.terminal_netnodes)
			})
		for wire in wires:
			data["wires"].append({
				"input_netnode_pos": str(wire.terminal_netnodes[0].pos),
				"output_netnode_pos_x": str(wire.terminal_netnodes[1].pos),
				"shared_id": wire.terminal_netnodes[0].id,
				"color": wire.color.to_html()
			})

		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(data, "\t"))
			print("Netlist exported to %s :D" % file_path)
		else:
			print(":c Failed to open file for writing: ", file_path)

	func _init(pos: Vector2):
		add_netnode_to_netlist(NetNode.new(pos, 0), false)

#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

var netlist: Netlist = Netlist.new(Vector2(50, 50))

var is_placing
var placement_start

var netnode1
var netnode2

func place_component(pos: Vector2 = Vector2(0, 0), type: ComponentTypes = ComponentTypes.RESISTOR):
	if is_placing:
		var pos2 = pos
		netnode2 = netlist.find_or_create_netnode(pos2.snapped(grid_size))
		netlist.add_component_to_netlist(Component.new(netnode1, netnode2, type))
		is_placing = false
		netlist.print_netlist()
	else:
		placement_start = pos
		netnode1 = netlist.find_or_create_netnode(placement_start.snapped(grid_size))
		is_placing = true
	queue_redraw()

func place_wire(pos: Vector2 = Vector2(0, 0), color: Color = Color.BLUE):
	if is_placing:
		var pos2 = pos
		netnode2 = netlist.find_or_create_netnode(pos2.snapped(grid_size), true)
		#var netnode1 = netlist.find_nearest_netnode(placement_start)
		#var netnode2 = netlist.find_nearest_netnode(pos2)
		#if netnode2 == null:
			#netnode2 = netlist.create_netnode(NetNode.new(NULL_NETNODE_ID, placement_start))
		#if netnode2 == null:
			#netnode2 = netlist.create_netnode(NetNode.new(NULL_NETNODE_ID, placement_start))
		netnode2.id = netnode1.id
		netlist.add_wire_to_netlist(Wire.new(netnode1, netnode2, color, 0))
		is_placing = false
		netlist.print_netlist() #DEBUG
	else:
		placement_start = pos
		netnode1 = netlist.find_or_create_netnode(placement_start.snapped(grid_size))
		is_placing = true
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_component(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			place_wire(event.position)

func _draw() -> void:
	for component in netlist.components:
		var pos1 = component.terminal_netnodes[0].pos
		var pos2 = component.terminal_netnodes[1].pos
		draw_line(pos1, pos2, Color.GREEN, 4)
	for wire in netlist.wires:
		#print("Drawing wire: (%d, %d)" % [wire.input_netnode.id, wire.output_netnode.id])
		var pos1 = wire.terminal_netnodes[0].pos
		var pos2 = wire.terminal_netnodes[1].pos
		draw_line(pos1, pos2, wire.color, 4)
	for netnode in netlist.netnodes:
		draw_circle(netnode.pos, 5, Color.WHITE if netnode.id != 0 else Color.YELLOW)
		draw_string(Corec.native_font, netnode.pos + Vector2(10, -10), str(netnode.id))

func transient_analisys():
	pass

#func _process(delta: float) -> void:
	#queue_redraw()
