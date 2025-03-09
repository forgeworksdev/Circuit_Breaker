@icon("uid://b1r8bj1my0h61")
extends Node2D

@onready var dialog_box: NinePatchRect = $DialogBox

@export var path_to_level: String

var is_interactable: bool = false

func _ready() -> void:
	dialog_box.modulate.a = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EngineerCharacter:
		self.is_interactable = true
		fade_dialog_in(dialog_box)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is EngineerCharacter:
		self.is_interactable = false
		fade_dialog_out(dialog_box)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and is_interactable == true:
		if !path_to_level.is_empty():
			get_tree().change_scene_to_file(path_to_level)
		else:
			print("Error: No level path specified")
	return

func fade_dialog_in(obj: CanvasItem):
	var tween = create_tween()
	tween.tween_property(obj, "modulate:a", 1, .5)

func fade_dialog_out(obj: CanvasItem):
	var tween = create_tween()
	tween.tween_property(obj, "modulate:a", 0, .5)
