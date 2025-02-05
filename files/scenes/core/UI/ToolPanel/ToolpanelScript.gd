extends Panel

@export var where_to_instantiate_wires: Node

@onready var cooldown: Timer = $Cooldown

var can_place_wire: bool = false  # Tracks whether wire placement is allowed

func _ready() -> void:
		pass

func _process(_delta: float) -> void:
		pass

func _input(event: InputEvent) -> void:
		# Check if the left mouse button is pressed and wire placement is allowed
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and can_place_wire:
				add_wire()  # Spawn a wire
				can_place_wire = false  # Disable further wire placement

# Function to add a wire
func add_wire():
		var wire = Wire_cb.new()
		wire.type_of_wire = Wire_cb.WireTypeEnum.NEUTRAL
		wire.position = get_global_mouse_position().snapped(Vector2(90, 90))
		wire.name = "Wire_CB" + str(randi() % 100 + 1)

		# Add the wire to the appropriate parent node
		if where_to_instantiate_wires != null:
				where_to_instantiate_wires.add_child(wire)
		else:
				self.add_child(wire)

# Handle the "Add Wire" button press
func _on_add_wire_button_pressed() -> void:
		can_place_wire = true  # Enable wire placement
