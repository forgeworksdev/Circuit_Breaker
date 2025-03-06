@icon("res://files/sprites/original_files/dialogBox.pxo")
extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animated_sprite_2d.play("default")
	AudioPlayerOne.change_song("res://files/audio/CircuitCoffeeBreak.mp3")
	AudioPlayerOne.loop = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("uid://ba4gnw142pu8a")

func _on_play_button_pressed() -> void:
	animation_player.play("run_away")

func _on_credits_pressed() -> void:
	OS.shell_open("http://kenney.nl/")

func _on_settings_pressed() -> void:
	pass

func _on_load_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
