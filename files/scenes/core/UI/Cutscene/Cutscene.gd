@icon("uid://dpfpc5gxvdwc5")
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var current_anim: int = 1

var animations: Dictionary = {
	1:
		"employer_intro",
	2:
		"bed_scene",
	3:
		"call_scene",
	4:
		"engineer_run_scene"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("employer_intro")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_anim > 3:
		get_tree().change_scene_to_file("res://files/scenes/core/UI/MainMenu/MainMenu.scn")
	else:
		animated_sprite_2d.play(animations[current_anim+1])
		current_anim += 1
