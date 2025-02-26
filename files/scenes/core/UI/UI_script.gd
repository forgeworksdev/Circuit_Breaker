@icon("res://files/sprites/others/icons/processor-symbolic.png") class_name UI_cb extends Control #PanelContainer

@export var ComponentContainer: Node

@export_category("Tool references")
@export var AddTool: AddTool_cb
@export var DelTool: DeleteTool_cb
@export var MoveTool: MoveTool_cb

@onready var level_objective_label: Label = $ObjectiveTray/CenterContainer/LevelObjectiveLabel

@export var level: Node

func ready():
#level_objective_label.text = level.level_objective
	pass

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
	#if ComponentContainer == null:
		#print("Error: No ComponentContainer")
	#else:
		#for child in ComponentContainer.get_children():
			#child.queue_free()


func _on_clear_button_pressed() -> void:
	disable_all_tools()


func disable_all_tools():
	AddTool.enabled = false
	DelTool.enabled = false
	MoveTool.enabled = false

#endregion


#region ComponentTray

var PSC_CC_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")
var PSC_CA_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")
#var PSC_SW_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")
#var PSC_ST_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")


var resistor_scene = preload("res://files/scenes/electrical_components/ResistorComponent/ResistorComponent.tscn")
var diode_scene = preload("res://files/scenes/electrical_components/DiodeComponent/DiodeComponent.scn")
var capacitor_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")
#var transistor_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")
var transformer_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")
var LED_scene = preload("res://files/scenes/electrical_components/PowerSourceComponent/PowerSourceComponent.scn")

func _on_add_psccc_button_pressed() -> void:
	var instance = PSC_CC_scene.instantiate()
	ComponentContainer.add_child(instance)



func _on_add_pscca_button_pressed() -> void:
	var instance = PSC_CA_scene.instantiate()
	ComponentContainer.add_child(instance)


#func _on_add_pscsw_button_pressed() -> void:
	#var instance = PSC_SW_scene.instantiate()
	#ComponentContainer.add_child(instance)


func _on_add_capacitor_button_pressed() -> void:
	var instance = capacitor_scene.instantiate()
	ComponentContainer.add_child(instance)


func _on_add_diode_button_pressed() -> void:
	var instance = diode_scene.instantiate()
	ComponentContainer.add_child(instance)


func _on_add_led_button_pressed() -> void:
	var instance = LED_scene.instantiate()
	ComponentContainer.add_child(instance)


func _on_add_transformer_button_pressed() -> void:
	var instance = transformer_scene.instantiate()
	ComponentContainer.add_child(instance)

#
#func _on_add_zener_diode_button_pressed() -> void:
	#pass


func _on_add_resistor_button_pressed() -> void:
	var instance = resistor_scene.instantiate()
	ComponentContainer.add_child(instance)

#func _on_add_transistor_button_pressed() -> void:
	#pass
#
#
#func _on_add_meter_button_pressed() -> void:
	#pass

#endregion
