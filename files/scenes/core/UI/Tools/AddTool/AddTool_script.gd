class_name AddTool_cb extends BaseTool_cb

var is_placing_wire: bool = false
var anim_speed: int = 5
var ignore_input: bool = false

@export var where_to_place_wire: Node

func _process(delta: float) -> void:
	super ._process(delta)

func add_wire():
	if where_to_place_wire == null:
		print("Error: where_to_place_wire = null")
		is_placing_wire = false
		return
	var wire = Wire_cb.new()
	wire.connect("was_placed", _wire_cb_was_placed)
	wire.position = get_global_mouse_position().snapped(wire.grid_size)
	where_to_place_wire.add_child(wire)
	wire.can_drag = true

func _wire_cb_was_placed():
		await get_tree().create_timer(0.1).timeout
		is_placing_wire = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_placing_wire:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and is_placing_wire == false:
		is_placing_wire = true
		add_wire()
