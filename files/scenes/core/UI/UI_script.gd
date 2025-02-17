@icon("res://files/sprites/others/icons/processor-symbolic.png") extends CanvasLayer #PanelContainer

#Exports
@export var wire_destination_node: Node

@export var tool_destination_node: Node

@export var component_destination_node: Node

@export var AddTool: Node
@export var DeleteTool: Node
@export var MoveTool: Node

@export var subpanel: Node
#Vars
#var AddTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/AddTool/AddTool.scn")
#var DeleteTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/DeleteTool/DeleteTool.scn")
#var MoveTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/MoveTool/MoveTool.scn")

func _ready() -> void:
	#tool_destination_node.add_child(AddTool.instantiate())
	#tool_destination_node.add_child(DeleteTool.instantiate())
	#tool_destination_node.add_child(MoveTool.instantiate())
	pass
func _process(delta: float) -> void:
	pass

var is_panel_up: bool =  false
func _on_add_wire_button_pressed() -> void:
	animate_subpanel()
	#disable_tools()
	#AddTool.enabled = true

func animate_subpanel():
	#is_panel_up != is_panel_up
	if is_panel_up == false:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(subpanel, "position", Vector2(32, 412), .4)
		is_panel_up = true
	else:
		var tween := create_tween()
		tween.tween_property(subpanel, "position", Vector2(32, 680), .2)
		is_panel_up = false

func _on_del_wire_button_pressed() -> void:
	disable_tools()
	DeleteTool.enabled = true

func _on_move_wire_sbutton_pressed() -> void:
	disable_tools()
	MoveTool.enabled = true


func _on_clear_button_pressed() -> void:
	if wire_destination_node != null and tool_destination_node != null and component_destination_node != null:
		for wire in wire_destination_node.get_children():
			wire.queue_free()
		for comp in component_destination_node.get_children():
			comp.queue_free()
	else:
		return

func disable_tools():
	for tool in tool_destination_node.get_children():
		tool.enabled = false

func _on_cancel_button_pressed() -> void:
	disable_tools()
