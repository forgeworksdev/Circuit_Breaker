@icon("res://files/sprites/others/icons/processor-symbolic.png") class_name UI_cb extends Control #PanelContainer



#DANGER DEPRECATE THIS SCRIPT ASAP!!! REPLACE WITH BUTTON MANAGER COMPONENTS



#Exports
@onready var subpanel: PanelContainer
@onready var tool_panel: PanelContainer = $ToolPanel
@export_category("Tools")
@export var AddTool: Node
@export var DeleteTool: Node
@export var MoveTool: Node
#@export var wire_destination_node: Node
#ss
#@export var tool_destination_node: Node
#
#@export var component_destination_node: Node
#

#
#@export var subpanel: Node
##Vars
##var AddTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/AddTool/AddTool.scn")
##var DeleteTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/DeleteTool/DeleteTool.scn")
##var MoveTool = preload("res://files/scenes/core/UI/ToolPanel/Tools/MoveTool/MoveTool.scn")
#s
func _ready() -> void:
	subpanel = $Subpanel
	##tool_destination_node.add_child(AddTool.instantiate())
	##tool_destination_node.add_child(DeleteTool.instantiate())
	##tool_destination_node.add_child(MoveTool.instantiate())
	#pass
#func _process(delta: float) -> void:
	#pass
#
#var is_panel_up: bool =  false
#
#func _on_del_wire_button_pressed() -> void:
	#disable_tools()
	#DeleteTool.enabled = true
#
#func _on_move_wire_sbutton_pressed() -> void:
	#disable_tools()
	#MoveTool.enabled = true
#
#
#func _on_clear_button_pressed() -> void:
	#if wire_destination_node != null and tool_destination_node != null and component_destination_node != null:
		#for wire in wire_destination_node.get_children():
			#wire.queue_free()
		#for comp in component_destination_node.get_children():
			#comp.queue_free()
	#else:
		#return
#
#func disable_tools():
	#for tool in tool_destination_node.get_children():
		#tool.enabled = false
#
#func _on_cancel_button_pressed() -> void:
	#disable_tools()
