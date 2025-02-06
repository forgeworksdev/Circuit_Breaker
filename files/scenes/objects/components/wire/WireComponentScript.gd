class_name Wire_cb
extends Line2D

#onreadys

#sometimes the game runs so fast that clicking once on the screen makes the first and second point have the same position, so i added a .5s delay in between the
#wire spawning and being able to drag it
@onready var cooldown_timer: Timer = Timer.new()

# Essas Area2D são instanciadas aqui, mas só são adicionadas como crianças desse node em _ready()
#			wire_start_area e wire_end_area são responsáveis por detectar conexões entre fios. Elas irão detectar colisões com
#			Outras wire_start/end_areas e wire_middle
#			 wire_middle_area é mais para ajudar entre as interações ferramenta-fio, tipo deleção e movimentação, mas ela tem outras aplicações estéticas.
@onready var wire_start_area = Area2D.new()
@onready var wire_end_area = Area2D.new()
@onready var wire_middle_area = Area2D.new()

# Essas caixas de colisão são necessárias para o funcionamento de Area2D
@onready var collision_shape_start = CollisionShape2D.new()
@onready var collision_shape_middle = CollisionShape2D.new()
@onready var collision_shape_end = CollisionShape2D.new()

#TIP @onready waits for the node to enter the scene tree before defining the variable, which avoids referencing an unexistent node.

#Enums
enum WireTypeEnum {PHASE, NEUTRAL, MIST = -1}

#exports
@export var type_of_wire: WireTypeEnum
@export var can_delete: bool = true
@export var can_drag: bool = false

#Consts
const MAX_POINTS: int = 3

#vars

var input_current: float = 0
var input_voltage: float = 0

var output_current: float = 0
var output_voltage: float = 0

# _init() modifica Line2D (base de Wire_cb) assim que ele é instanciado. Só deve-se usar essa função para modificar traços que são constantes.
func _init() -> void:
	self.begin_cap_mode = Line2D.LINE_CAP_BOX
	self.end_cap_mode = Line2D.LINE_CAP_BOX
	self.joint_mode = Line2D.LINE_JOINT_ROUND
	self.width = 4
	self.add_point(Vector2.ZERO)
	self.add_point(Vector2.ZERO)
	#self.scale = Vector2(.4, .4)

# _ready() Modifica a aparência do fio, adiciona as Area2D, inicia um cooldown
func _ready() -> void:
	print(str(self.name) + "was added into the scene tree! (Wire_cb)")
	match type_of_wire:
		WireTypeEnum.PHASE:
			self.default_color = Color.RED
			print(str(self.name) + "is a Phase wire")
		WireTypeEnum.NEUTRAL:
			self.default_color = Color.BLUE
			print(str(self.name) + "is a Neutral wire")
		WireTypeEnum.MIST:
			self.default_color = Color.PURPLE
			print(str(self.name) + "is a Mist wire (connected to AC)")

	cooldown_timer.wait_time = 0.5
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)

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

#End of _ready()

func _process(_delta: float) -> void:
	update_positions()
	if not can_drag or get_point_count() >= MAX_POINTS:
		return

	var local_mouse_pos = to_local(get_global_mouse_position().snapped(Vector2(90, 90)))
	set_point_position(get_point_count() - 1, local_mouse_pos)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_point_count() < MAX_POINTS and cooldown_timer.is_stopped():
		add_point(local_mouse_pos)
		#cooldown_timer.start()

#WARNING this should be part of the autoload Corec or part of the toolbar. This is an UI command afaik
#se esc for pressionado, pare de arrastar
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			can_drag = false

#region Others
#Chamada por _ready() e _process(delta: float). ajusta a posição de collision_shape_middle, alinhando com os pontos de Line2D e faz o mesmo com wire_start/end_area
func update_positions():
	if points.size() >= 2:
		wire_start_area.global_position = to_global(get_point_position(0))
		wire_end_area.global_position = to_global(get_point_position(get_point_count() - 1))
		collision_shape_middle.shape.a = (get_point_position(0))
		collision_shape_middle.shape.b = (get_point_position(get_point_count() - 1))

#Why isn't this a built_in method in all classes? ;-;
#...checks if two nodes are siblings.... ig?
func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()
#endregion

#region Signals

#DANGER IN DEVELOPMENT
func wire_start_area_entered(area: Area2D):
	if !are_siblings(wire_start_area, area):
		#area.get_parent().output_voltage = self.input_voltage
		print("INDEV!")

func wire_middle_area_entered(area: Area2D):
	if !are_siblings(wire_middle_area, area):
		print("INDEV!")

func wire_end_area_entered(area: Area2D):
	if !are_siblings(wire_end_area, area):
		#area.get_parent().input_voltage = self.output_voltage
		print("INDEV!")

func _on_cooldown_timeout() -> void:
	can_drag = true
#endregion
