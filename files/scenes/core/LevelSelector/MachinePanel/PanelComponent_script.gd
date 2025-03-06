@icon("uid://b1r8bj1my0h61")
extends Node2D

@export var path_to_level: String

@onready var play_dialog: NinePatchRect = $PlayDialog

var interactable: bool = false

func _ready() -> void:
	play_dialog.modulate.a = 0

func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EngineerCharacter:
		self.interactable = true
		fade_dialog_in()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is EngineerCharacter:
		self.interactable = false
		fade_dialog_out()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and interactable == true:
		get_tree().change_scene_to_file(path_to_level)
	pass

func fade_dialog_in():
	var tween = create_tween()
	tween.tween_property(play_dialog, "modulate:a", 1, .5)

func fade_dialog_out():
	var tween = create_tween()
	tween.tween_property(play_dialog, "modulate:a", 0, .5)
