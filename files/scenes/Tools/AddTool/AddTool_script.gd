extends Node2D
#Onreadys
@onready var vfx: ColorRect = $vfx

#Vars
var can_place_wire: bool

#Exports
@export var enabled: bool

@export var where_to_place_wire: Node

func _ready() -> void:
	pass

var phase_speed: int = 5
func _process(delta: float) -> void:
	if enabled:
		self.position = get_global_mouse_position()
		var material = vfx.material
		if material is ShaderMaterial:
			var phase = material.get_shader_parameter("phase")
			material.set_shader_parameter("phase", phase + delta * phase_speed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and can_place_wire == true:
		add_wire()

func add_wire():
	var wire = Wire_cb.new()
	wire.grid_size = Vector2(90,90)
	wire.position = get_global_mouse_position().snapped(wire.grid_size)
	where_to_place_wire.add_child(wire)
	wire.can_drag = true
	can_place_wire = false


func _on_add_wire_button_pressed() -> void:
	can_place_wire = true
