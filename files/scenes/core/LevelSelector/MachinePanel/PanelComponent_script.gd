extends Node2D

@export var path_to_level: String

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect

var can_interact: bool = false

func _ready() -> void:
	nine_patch_rect.modulate.a = 0

func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EngineerCharacter:
		self.can_interact = true
		fade_dialog_in()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is EngineerCharacter:
		self.can_interact = false
		fade_dialog_out()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and can_interact == true:
		get_tree().change_scene_to_file(path_to_level)
	pass

func fade_dialog_in():
	var tween = create_tween()
	tween.tween_property(nine_patch_rect, "modulate:a", 1, 1)

func fade_dialog_out():
	var tween = create_tween()
	tween.tween_property(nine_patch_rect, "modulate:a", 0, 1)
