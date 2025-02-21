@icon("res://files/sprites/exported/base_comp.png")
class_name Component_cb extends Node2D

#Enums

#enum ComponentTypeEnum {
	#ACTIVE, ##Generates voltage and current to achieve the expected result.
	#PASSIVE ##Modifies current and voltage to achieve the expected result
#}

#Exports

###Defines the type of component
#@export var type_of_comp: ComponentTypeEnum

##Defines if the component is being powered
@export var is_powered: bool
##Defines if the component can be erased with the delete tool
@export var can_delete: bool
##Defines if the component is polarized
@export var is_polarized: bool

@export_category("Values")
@export var resistance: float
@export var max_current: float
@export var max_voltage: float

@export_category("Collisions")
@export var input_area: Area2D
@export var output_area: Area2D
@export var main_area: Area2D

var is_burnt: bool

#Vars

var input_point:int = 0
var output_point: int = randi_range(1, 1000)

var voltage: float = 0.0

var current: float = 0.0

var is_connected_to_PSU: bool = false

func _ready() -> void:
	input_area.connect("area_entered", input_area_entered)
	input_area.connect("area_exited", input_area_exited)
	output_area.connect("area_entered", output_area_entered)
	output_area.connect("area_exited", output_area_exited)

#func _process(delta: float) -> void:
	#sync_values()

func input_area_entered(area: Area2D):
	connect_input_components(area)

func output_area_entered(area: Area2D):
	connect_output_components(area)

func input_area_exited(area: Area2D):
	disconnect_components(area)

func output_area_exited(area: Area2D):
	disconnect_components(area)

func get_voltage() -> float:
	return voltage

func get_current() -> float:
	return current

func set_voltage(new_voltage: float = 0) -> void:
	if self.input_voltage != new_voltage:
		voltage = new_voltage
#
func set_current(new_current: float = 0):
	if self.input_current != new_current:
		current = new_current

func connect_input_components(area: Area2D) -> void:
	if (area.get_parent() is Component_cb or area.get_parent() is Wire_cb):
		if !are_siblings(area, output_area):
			var other_node := area.get_parent()
			input_point = other_node.output_point

func connect_output_components(area: Area2D):
	if area.get_parent() is Component_cb or area.get_parent() is Wire_cb:
		if !are_siblings(area, output_area):
			var other_node := area.get_parent()
			if other_node is Wire_cb:
				other_node.output_point = output_point
			if other_node is Component_cb:
				other_node.input_point = output_point


func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()

func disconnect_components(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent == null:
		return
	if area.get_parent() is Wire_cb or area.get_parent() is Component_cb:
		var has_remaining_overlaps := false
		for overlapping_area in input_area.get_overlapping_areas() + output_area.get_overlapping_areas():
			if overlapping_area.get_parent() == parent:
				has_remaining_overlaps = true
				break
		if not has_remaining_overlaps:
			print("Disconnecting component: ", parent.name)
			input_point = 0
