@icon("res://files/sprites/exported/base_comp.png")
class_name BaseComponent_cb extends Node2D

#Enums

enum ComponentTypeEnum {
	ACTIVE, ##Generates voltage and current to achieve the expected result.
	PASSIVE ##Modifies current and voltage to achieve the expected result
	= -1
}

#Exports

##Defines the type of component
@export var type_of_comp: ComponentTypeEnum

##Defines if the component can be erased with the delete tool
@export var can_delete: bool

##Defines if the component is polarized
@export var is_polarized: bool

@export var input_area: Area2D
@export var output_area: Area2D
@export var main_area: Area2D

#Vars

var input_current: float = 0
var input_voltage: float = 0

var output_current: float = 0
var output_voltage: float = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
