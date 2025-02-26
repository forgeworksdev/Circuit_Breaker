extends CharacterBody2D
class_name EngineerCharacter

@export var sprite: AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -200.0

var enabled: bool = true

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta
	if enabled:
		# Handle jumping
		if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("up_button")) and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Handle horizontal movement
		var direction := Input.get_axis("left_button", "right_button")
		if direction:
			velocity.x = direction * SPEED
			sprite.play("Sprint")
			# Flip sprite based on input direction
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			sprite.play("Idle")

		# Move the character
	move_and_slide()
