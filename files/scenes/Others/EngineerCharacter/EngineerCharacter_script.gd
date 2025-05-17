@icon("res://files/sprites/original_files/electrical_eng_ref.pxo")
extends CharacterBody2D
class_name EngineerMC_cb

@export var sprite: AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -250.0

var enabled: bool = true

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if enabled:
		if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("up_button")) and is_on_floor():
			velocity.y = JUMP_VELOCITY
		var direction := Input.get_axis("left_button", "right_button")
		if direction:
			velocity.x = direction * SPEED
			sprite.play("Sprint")
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			sprite.play("Idle")
	move_and_slide()
