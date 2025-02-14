@icon("res://files/sprites/exported/breaker.png") extends BaseComponent_cb

#Exports
@export var is_on: bool

func _ready() -> void:
	type_of_comp = ComponentTypeEnum.PASSIVE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
