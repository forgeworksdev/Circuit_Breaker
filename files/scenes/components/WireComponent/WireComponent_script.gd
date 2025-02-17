class_name Wire_cb
extends Line2D

#Enums

#Exports

#Vars
var snap_to_grid: bool = true
var grid_size: Vector2 = Vector2(16, 16)

var can_drag: bool = false
var is_placed: bool = false

var _voltage: float = 0.0
var voltage: float:
	set(new_voltage):
		_voltage = new_voltage
		sync_values()
	get:
		return _voltage

var _current: float = 0.0
var current: float:
	set(new_current):
		_current = new_current
		sync_values()
	get:
		return _current

var is_connected_to_PSU_minus: bool

var connected_wires: Array = []

var wire_start_area :=  Area2D.new()
var start_area_collision := CollisionShape2D.new()

var wire_middle_area :=  Area2D.new()
var middle_area_collision := CollisionShape2D.new()

var wire_end_area :=  Area2D.new()
var end_area_collision := CollisionShape2D.new()

#Consts
const MAX_POINTS: int = 2

#Signals
signal was_placed

func _init() -> void:
	self.begin_cap_mode = Line2D.LINE_CAP_BOX
	self.end_cap_mode = Line2D.LINE_CAP_BOX
	self.joint_mode = Line2D.LINE_JOINT_ROUND
	self.width = 4
	self.add_point(Vector2.ZERO)
	self.add_point(Vector2(16,16))

func _ready() -> void:
	print(str(self.name) + "was added into the scene tree! (Wire_cb)")

	add_child(wire_start_area)
	wire_start_area.add_child(start_area_collision)
	start_area_collision.shape = CircleShape2D.new()
	wire_start_area.connect("area_entered", wire_start_area_entered)
	wire_start_area.connect("area_exited", wire_start_area_exited)

	add_child(wire_middle_area)
	wire_middle_area.add_child(middle_area_collision)
	middle_area_collision.shape = SegmentShape2D.new()
	wire_middle_area.connect("area_entered", wire_middle_area_entered)
	wire_middle_area.connect("area_exited", wire_middle_area_exited)

	add_child(wire_end_area)
	wire_end_area.add_child(end_area_collision)
	end_area_collision.shape = CircleShape2D.new()
	wire_end_area.connect("area_entered", wire_end_area_entered)
	wire_end_area.connect("area_exited", wire_end_area_exited)

	can_drag = true

func _process(delta: float) -> void:
	update_collisionshape_positions()
	#sync_values()
	if not can_drag:
		return

	if can_drag and is_placed == false:
		var local_mouse_pos = to_local(get_global_mouse_position())
		set_point_position(get_point_count() - 1, local_mouse_pos.snapped(grid_size))

func update_collisionshape_positions() -> void:
	if points.size() >= 2:
		wire_start_area.global_position = to_global(get_point_position(0))
		wire_end_area.global_position = to_global(get_point_position(get_point_count() - 1))
		middle_area_collision.shape.a = get_point_position(0)
		middle_area_collision.shape.b = get_point_position(get_point_count() - 1)

func get_voltage() -> float:
	#print(str(voltage))
	return voltage

func get_current() -> float:
	#print(str(current))
	return current

func set_voltage(new_voltage: float = 0) -> void:
	if voltage != new_voltage:
		voltage = new_voltage

func set_current(new_current: float = 0):
	if current != new_current:
		current = new_current

func sync_values() -> void:
	for wire in connected_wires:
		wire.set_voltage(self.voltage)
		wire.set_current(self.current)
		#print("Sync-ed wire voltage")

func are_siblings(node_a, node_b) -> bool:
	#print(str(node_a.get_parent()))
	#print(str(node_b.get_parent()))
	#print(str(node_a.get_parent() == node_b.get_parent()))
	return node_a.get_parent() == node_b.get_parent()

func wire_start_area_entered(area: Area2D) -> void:
	print("A")
	connect_components(area)

func wire_middle_area_entered(area: Area2D) -> void:
	pass

func wire_end_area_entered(area: Area2D) -> void:
	print("A")
	connect_components(area)

func wire_start_area_exited(area: Area2D) -> void:
	disconnect_components(area)

func wire_middle_area_exited(area: Area2D) -> void:
	pass

func wire_end_area_exited(area: Area2D) -> void:
	disconnect_components(area)

func disconnect_components(area: Area2D):
	print("a")
	if area.get_parent() in connected_wires:
		connected_wires.erase(area.get_parent())

func connect_components(area: Area2D) -> void:
	#if !can_drag:
	if (area.get_parent() is BaseComponent_cb or area.get_parent() is Wire_cb):
		if !are_siblings(area, wire_end_area):
			#and area.get_child(0).shape == CircleShape2D:
			var other_node := area.get_parent()
			if other_node not in connected_wires:
				connected_wires.append(other_node)
				#print("Connected a wire")


#	DEBUG
func _input(event: InputEvent) -> void:
	#is_inside_cooldown(event)
	#if is_in_cooldown:
		#pass
	var local_mouse_pos = to_local(get_global_mouse_position())
	if Input.is_action_just_pressed("clicked") and can_drag == true and is_placed == false:
		set_point_position(get_point_count() - 1, local_mouse_pos.snapped(grid_size))
		was_placed.emit()
		can_drag = false
		is_placed = true
	if event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.pressed:
					can_drag = false

#var is_in_cooldown: bool
#var last_click_time: float = -1.0
#var click_cooldown: float = 0.2
#func is_inside_cooldown(event: InputEvent):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			#var current_time = Time.get_unix_time_from_system()
			#if last_click_time == -1.0 or current_time - last_click_time >= click_cooldown:
					#last_click_time = current_time
					#is_in_cooldown = false
			#else:
					#is_in_cooldown = true
