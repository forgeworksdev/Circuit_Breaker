extends Node2D
#Onreadys
@onready var vfx: ColorRect = $vfx

#Vars
var is_placing_wire: bool = false
var anim_speed: int = 5


#Exports
@export var enabled: bool
@export var where_to_place_wire: Node

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if enabled:
		self.position = get_global_mouse_position()
		var material = vfx.material
		if material is ShaderMaterial:
			var phase = material.get_shader_parameter("phase")
			material.set_shader_parameter("phase", phase + delta * anim_speed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and is_placing_wire == false: #and can_place_wire == true:
		if not is_placing_wire:
			is_placing_wire = true
			add_wire()


func add_wire():
	if where_to_place_wire == null:
		print("Error: where_to_place_wire == null")
		is_placing_wire = false
		return
	var wire = Wire_cb.new()
	wire.connect("was_placed", _wire_cb_was_placed.bind(wire))
	wire.position = get_global_mouse_position().snapped(wire.grid_size)
	where_to_place_wire.add_child(wire)
	wire.can_drag = true

func _wire_cb_was_placed(wire):
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(wire) and wire.get_parent():
		is_placing_wire = false
