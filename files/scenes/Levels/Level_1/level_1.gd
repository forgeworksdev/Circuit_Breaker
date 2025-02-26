extends Node2D

@export var level_objective: String
@export var UI: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI.level_objective_label.text = level_objective


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
