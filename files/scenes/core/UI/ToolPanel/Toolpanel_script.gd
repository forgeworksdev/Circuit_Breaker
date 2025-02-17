@icon("res://files/sprites/others/icons/processor-symbolic.png") extends PanelContainer

#Exports
@export var wire_destination_node: Node

@export var tool_destination_node: Node

@export var component_destination_node: Node

#Vars
var AddTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/AddTool/AddTool.scn")
var DeleteTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/DeleteTool/DeleteTool.scn")
var MoveTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/MoveTool/MoveTool.scn")
var can_place_wire: bool

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and can_place_wire == true:
		add_wire()

func add_wire():
	var wire = Wire_cb.new()
	#wire.grid_size = Vector2(90,90)
	wire.position = get_global_mouse_position().snapped(Vector2(16,16))
	#wire.set_point_position(wire.get_point_count() - 2, get_global_mouse_position().snapped(Vector2(16,16)))
	wire_destination_node.add_child(wire)
	wire.can_drag = true
	can_place_wire = false


func _on_add_wire_button_pressed() -> void:
	can_place_wire = true
	#if !tool_destination_node.has_node("AddTool"):
		#var tool = AddTool.instantiate()
		#tool.name = "AddTool"
		#tool.where_to_place_wire = wire_destination_node
		#tool.enabled = true
		#tool_destination_node.add_child(tool)

func _on_del_wire_button_pressed() -> void:
	#can_place_wire = false
	if !tool_destination_node.has_node("DelTool"):
		var tool = DeleteTool.instantiate()
		tool.name = "DelTool"
		tool.enabled = true
		tool_destination_node.add_child(tool)

func _on_move_wire_sbutton_pressed() -> void:
	#can_place_wire = false
	if !tool_destination_node.has_node("MoveTool"):
		var tool = AddTool.instantiate()
		tool.name = "MoveTool"
		tool.enabled = true
		tool_destination_node.add_child(tool)


func _on_clear_button_pressed() -> void:
	if wire_destination_node != null and tool_destination_node != null and component_destination_node != null:
		for wire in wire_destination_node.get_children():
			wire.queue_free()
		for tool in tool_destination_node.get_children():
			tool.queue_free()
		for comp in component_destination_node.get_children():
			comp.queue_free()
	else:
		return
