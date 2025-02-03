class_name Wire_CB
extends Line2D

@export var type_of_wire: WireTypeEnum
enum WireTypeEnum {PHASE, NEUTRAL, MIST = -1}

const MAX_POINTS: int = 3
var can_drag: bool = false

var area_start = Area2D.new()
var area_end = Area2D.new()
var area_middle = Area2D.new()

var collision_shape_start = CollisionShape2D.new()
var collision_shape_middle = CollisionShape2D.new()
var collision_shape_end = CollisionShape2D.new()

@onready var cooldown_timer: Timer = Timer.new()  # Timer for cooldown

func _init() -> void:
	self.begin_cap_mode = Line2D.LINE_CAP_BOX
	self.end_cap_mode = Line2D.LINE_CAP_BOX
	self.joint_mode = Line2D.LINE_JOINT_ROUND
	self.width = 1
	self.add_point(Vector2.ZERO)
	self.add_point(Vector2.ZERO)
	self.scale = Vector2(.4, .4)

func _ready() -> void:
	# Initialize the cooldown timer
	cooldown_timer.wait_time = 0.5
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)

	match type_of_wire:
		WireTypeEnum.PHASE:
			print("Phase wire")
		WireTypeEnum.NEUTRAL:
			print("Neutral wire")
		WireTypeEnum.MIST:
			print("Mist wire (AC)")

	collision_shape_start.shape = CircleShape2D.new()
	collision_shape_middle.shape = SegmentShape2D.new()
	collision_shape_end.shape = CircleShape2D.new()

	area_start.connect("area_entered", area_start_entered)
	area_middle.connect("area_entered", area_middle_entered)
	area_end.connect("area_entered", area_end_entered)

	update_positions()

	area_start.name = "Area_start"
	area_middle.name = "area_middle"
	area_end.name = "Area_end"
	area_start.monitoring = true
	area_middle.monitoring = true
	area_end.monitoring = true
	add_child(area_start)
	add_child(area_middle)
	add_child(area_end)
	area_start.add_child(collision_shape_start)
	area_middle.add_child(collision_shape_middle)
	area_end.add_child(collision_shape_end)

	cooldown_timer.start()

func _process(_delta: float) -> void:
	update_positions()
	if not can_drag or get_point_count() >= MAX_POINTS:
		return

	var local_mouse_pos = to_local(get_global_mouse_position())
	local_mouse_pos = local_mouse_pos
	set_point_position(get_point_count() - 1, local_mouse_pos)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_point_count() < MAX_POINTS and cooldown_timer.is_stopped():
		add_point(local_mouse_pos)

func update_positions():
	if points.size() >= 2:
		area_start.global_position = to_global(get_point_position(0))
		area_end.global_position = to_global(get_point_position(get_point_count() - 1))
		collision_shape_middle.shape.a = (get_point_position(0))
		collision_shape_middle.shape.b = (get_point_position(get_point_count() - 1))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			can_drag = false

func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()

func area_start_entered(area: Area2D):
	if !are_siblings(area_start, area):
		print("HAH!")

func area_middle_entered(area: Area2D):
	if !are_siblings(area_middle, area):
		print("HAH!")

func area_end_entered(area: Area2D):
	if !are_siblings(area_end, area):
		print("HAH!")

func _on_cooldown_timeout() -> void:
	can_drag = true
