extends Node2D

@export var enabled: bool
@onready var vfx: ColorRect = $vfx

var object: Area2D
var entered:bool

func _ready():
	pass

var phase_speed: int = 5
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and entered == true:
		if object.get_parent().can_delete:
			object.get_parent().queue_free()
			print("INDEV")

	if enabled:
		self.position = get_global_mouse_position()
		var material = vfx.material
		if material is ShaderMaterial:
			var phase = material.get_shader_parameter("phase")
			material.set_shader_parameter("phase", phase + delta * phase_speed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.queue_free()
	print("INDEV")



func _on_area_2d_2_area_entered(area: Area2D) -> void:
	object = area
	entered = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	object = null
	entered = false
