@icon("res://files/sprites/others/icons/processor-symbolic.png") extends PanelContainer

#Exports
@export var where_to_place_wire: Node

@export var tool_destination_node: Node

#Vars
var AddTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/AddTool/AddTool.scn")
var DeleteTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/DeleteTool/DeleteTool.scn")
var MoveTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/MoveTool/MoveTool.scn")
var can_place_wire: bool

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and can_place_wire == true:
		#add_wire()
#
#func add_wire():
	#var wire = Wire_cb.new()
	##wire.grid_size = Vector2(90,90)
	#wire.position = get_global_mouse_position().snapped(wire.grid_size)
	#where_to_place_wire.add_child(wire)
	#wire.can_drag = true
	#can_place_wire = false


func _on_add_wire_button_pressed() -> void:
	#can_place_wire = true
	var tool = AddTool.instantiate()
	tool.enabled = true
	tool_destination_node.add_child(tool)

func _on_del_wire_button_pressed() -> void:
	#can_place_wire = false
	var tool = DeleteTool.instantiate()
	tool.enabled = true
	tool_destination_node.add_child(tool)

func _on_move_wire_button_pressed() -> void:
	#can_place_wire = false
	var tool = AddTool.instantiate()
	tool.enabled = true
	tool_destination_node.add_child(tool)
