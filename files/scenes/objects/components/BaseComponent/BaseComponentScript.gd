class_name BaseComponent_cb extends Node2D

enum ComponentTypeEnum {ACTIVE, PASSIVE = -1}

@export var type_of_wire: ComponentTypeEnum

@export var can_delete: bool
@export var is_polarized: bool

var input_current: float = 0
var input_voltage: float = 0

var output_current: float = 0
var output_voltage: float = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
