class_name Wire_cb
extends Line2D

#Enums

#Exports

#Vars
var can_delete: bool = true
var snap_to_grid: bool = true
var grid_size: Vector2 = Vector2(16, 16)
var is_connected_to_comp: bool
#var grid_size: Vector2 = Vector2(4, 4)

var can_drag: bool = false
var is_placed: bool = false

var wire_start_area :=  Area2D.new()
var start_area_collision := CollisionShape2D.new()

var wire_middle_area :=  Area2D.new()
var middle_area_collision := CollisionShape2D.new()

var wire_end_area :=  Area2D.new()
var end_area_collision := CollisionShape2D.new()

var output_point: int = 0

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
	if not can_drag:
		return

	if can_drag and is_placed == false:
		var local_mouse_pos = to_local(get_global_mouse_position())
		set_point_position(get_point_count() - 1, local_mouse_pos.snapped(grid_size))

func _input(event: InputEvent) -> void:

	var local_mouse_pos = to_local(get_global_mouse_position())

	if Input.is_action_just_pressed("click") and can_drag == true and is_placed == false:
		set_point_position(get_point_count() - 1, local_mouse_pos.snapped(grid_size))
		was_placed.emit()
		can_drag = false
		is_placed = true

	if event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.pressed:
					can_drag = false


func update_collisionshape_positions() -> void:
	if points.size() >= 2:
		wire_start_area.global_position = to_global(get_point_position(0))
		wire_end_area.global_position = to_global(get_point_position(get_point_count() - 1))
		middle_area_collision.shape.a = get_point_position(0)
		middle_area_collision.shape.b = get_point_position(get_point_count() - 1)

func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()

func wire_start_area_entered(area: Area2D) -> void:
	connect_components(area)

func wire_middle_area_entered(area: Area2D) -> void:
	pass

func wire_end_area_entered(area: Area2D) -> void:
	connect_components(area)

func wire_start_area_exited(area: Area2D) -> void:
	disconnect_components(area)

func wire_middle_area_exited(area: Area2D) -> void:
	pass

func wire_end_area_exited(area: Area2D) -> void:
	disconnect_components(area)

func connect_components(area):
	pass

func disconnect_components(area):
	pass

#var connected_wires: Array[Wire_cb] = []
#var is_connected: bool = false
#
#func connect_components(area: Area2D) -> void:
	#if not (area.get_parent() is Component_cb or area.get_parent() is Wire_cb) or are_siblings(area, wire_end_area):
		#return
	#var other_node := area.get_parent()
	#if other_node is Wire_cb:
		#if is_connected:
			#output_point = other_node.output_point
			#for wire in connected_wires:
				#wire.output_point = other_node.output_point
		##if other_node.output_point == 0:
		#other_node.output_point = output_point
		#is_connected = true
		##elif other_node.output_point != 0:
			##output_point = other_node.output_point
		#if other_node not in connected_wires:
			#connected_wires.append(other_node)
#
#func disconnect_components(area: Area2D) -> void:
	#var parent = area.get_parent()
	#if parent == null:
		#print("Warning: Area has no parent. Cannot disconnect.")
		#return
	#if parent is Wire_cb or area.get_parent() is Component_cb:
		#var has_remaining_overlaps := false
		#for overlapping_area in wire_end_area.get_overlapping_areas() + wire_start_area.get_overlapping_areas():
			#if overlapping_area.get_parent() == parent:
				#has_remaining_overlaps = true
				#break
		#if not has_remaining_overlaps:
			#output_point = 0
			#if parent in connected_wires:
				#connected_wires.erase(parent)
