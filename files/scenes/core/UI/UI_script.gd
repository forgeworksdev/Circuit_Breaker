@icon("res://files/sprites/others/icons/processor-symbolic.png") class_name UI_cb extends CanvasLayer#PanelContainer

@onready var level_objective_label: Label = $ObjectiveTray/CenterContainer/LevelObjectiveLabel

@export var ComponentContainer: Node

@export_category("Tool references")
@export var AddTool: AddTool_cb
@export var DelTool: DeleteTool_cb
@export var MoveTool: MoveTool_cb

var level: Node



func _ready() -> void:
	level = get_tree().current_scene
	level_objective_label.text = level.get_level_objective()

func get_level_objective():
	return "debug"

#region ToolPanel

func _on_add_tool_button_pressed() -> void:
	disable_all_tools()
	AddTool.enabled = true

func _on_del_tool_button_pressed() -> void:
	disable_all_tools()
	DelTool.enabled = true

func _on_move_tool_button_pressed() -> void:
	disable_all_tools()
	MoveTool.enabled = true

func _on_cancel_button_pressed() -> void:
	disable_all_tools()

func _on_clear_button_pressed() -> void:
	disable_all_tools()

func disable_all_tools():
	AddTool.enabled = false
	DelTool.enabled = false
	MoveTool.enabled = false

#endregion

#region ComponentTray

func add_component(path_to_component_scene: String, where_to_instantiate: Node = ComponentContainer) -> void:
	if not path_to_component_scene.is_empty():
		var instance = load(path_to_component_scene).instantiate()
		ComponentContainer.add_child(instance)

#endregion
