class_name BaseTool_cb extends Node2D

@export var enabled: bool


@export var vfx: ColorRect

#func _ready() -> void:
	#super._ready()
#func _process(delta: float) -> void:
	#super ._process(delta)

var phase_speed: int = 5
func _process(delta: float) -> void:
	if enabled:
		visible = true
		self.position = get_global_mouse_position()
		var material = vfx.material
		if material is ShaderMaterial:
			var phase = material.get_shader_parameter("phase")
			material.set_shader_parameter("phase", phase + delta * phase_speed)
	else:
		self.visible = false
		self.position = Vector2(-10, -10)
		return
