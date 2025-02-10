extends PanelContainer

#Vars
var can_place_wire: bool
@export var where_to_place_wire: Node

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

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


func _on_del_wire_button_pressed() -> void:
	can_place_wire = false


func _on_move_wire_button_pressed() -> void:
	can_place_wire = false
