class_name Wire_cb
extends Line2D

@onready var cooldown_timer: Timer = Timer.new()

enum WireTypeEnum {PHASE, NEUTRAL, MIST = -1}

@export var type_of_wire: WireTypeEnum
@export var can_delete: bool

const MAX_POINTS: int = 3
@export var can_drag: bool = false

var wire_start_area = Area2D.new()
var wire_end_area = Area2D.new()
var wire_middle_area = Area2D.new()

var collision_shape_start = CollisionShape2D.new()
var collision_shape_middle = CollisionShape2D.new()
var collision_shape_end = CollisionShape2D.new()

func _init() -> void:
	self.begin_cap_mode = Line2D.LINE_CAP_BOX
	self.end_cap_mode = Line2D.LINE_CAP_BOX
	self.joint_mode = Line2D.LINE_JOINT_ROUND
	self.width = 4
	self.add_point(Vector2.ZERO)
	self.add_point(Vector2.ZERO)
	#self.scale = Vector2(.4, .4)

func _ready() -> void:
	if type_of_wire == Wire_cb.WireTypeEnum.NEUTRAL:
		self.default_color = Color.BLUE
	if type_of_wire == Wire_cb.WireTypeEnum.MIST:
		self.default_color = Color.PURPLE
	if type_of_wire == Wire_cb.WireTypeEnum.PHASE:
		self.default_color = Color.RED
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

	wire_start_area.connect("area_entered", wire_start_area_entered)
	wire_middle_area.connect("area_entered", wire_middle_area_entered)
	wire_end_area.connect("area_entered", wire_end_area_entered)

	update_positions()

	wire_start_area.name = "Area_start"
	wire_middle_area.name = "wire_middle_area"
	wire_end_area.name = "Area_end"
	wire_start_area.monitoring = true
	wire_middle_area.monitoring = true
	wire_end_area.monitoring = true
	add_child(wire_start_area)
	add_child(wire_middle_area)
	add_child(wire_end_area)
	wire_start_area.add_child(collision_shape_start)
	wire_middle_area.add_child(collision_shape_middle)
	wire_end_area.add_child(collision_shape_end)

	cooldown_timer.start()

func _process(_delta: float) -> void:
	update_positions()
	if not can_drag or get_point_count() >= MAX_POINTS:
		return

	var local_mouse_pos = to_local(get_global_mouse_position().snapped(Vector2(90, 90)))
	set_point_position(get_point_count() - 1, local_mouse_pos)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_point_count() < MAX_POINTS and cooldown_timer.is_stopped():
		add_point(local_mouse_pos)
		#cooldown_timer.start()

func update_positions():
	if points.size() >= 2:
		wire_start_area.global_position = to_global(get_point_position(0))
		wire_end_area.global_position = to_global(get_point_position(get_point_count() - 1))
		collision_shape_middle.shape.a = (get_point_position(0))
		collision_shape_middle.shape.b = (get_point_position(get_point_count() - 1))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			can_drag = false

func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()

func wire_start_area_entered(area: Area2D):
	if !are_siblings(wire_start_area, area):
		print("INDEV!")

func wire_middle_area_entered(area: Area2D):
	if !are_siblings(wire_middle_area, area):
		print("INDEV!")

func wire_end_area_entered(area: Area2D):
	if !are_siblings(wire_end_area, area):
		print("INDEV!")

func _on_cooldown_timeout() -> void:
	can_drag = true
