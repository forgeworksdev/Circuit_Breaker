@icon("res://files/sprites/exported/base_comp.png")
class_name Component_cb
extends Node2D

# Exports
@export var can_delete: bool
@export var is_polarized: bool

@export_category("Values")
@export var resistance: float
@export var max_current: float
@export var max_voltage: float

@export_category("Collisions")
@export var input_area: Area2D
@export var output_area: Area2D
@export var main_area: Area2D

# Vars
var input_point: int = 0
var output_point: int = 0  # Will be assigned a unique value

var voltage: float = 0.0  # Will be assigned by another component
var current: float = 0.0  # Will be assigned by another component
var power: float = 0.0    # Will be assigned by another component

var is_burnt: bool = false

# Track connected components and wires
var connected_inputs: Array = []  # Components/wires connected to input_area
var connected_outputs: Array = [] # Components/wires connected to output_area

func _ready() -> void:
	# Assign a unique output_point
	output_point = Corec.get_unique_output_point()

	# Connect signals for collision areas
	input_area.connect("area_entered", Callable(self, "_on_input_area_entered"))
	input_area.connect("area_exited", Callable(self, "_on_input_area_exited"))
	output_area.connect("area_entered", Callable(self, "_on_output_area_entered"))
	output_area.connect("area_exited", Callable(self, "_on_output_area_exited"))

# Handle input area entered
func _on_input_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Component_cb or parent is Wire_cb:
		if !are_siblings(area, output_area):
			connect_input(parent)

# Handle output area entered
func _on_output_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Component_cb or parent is Wire_cb:
		if !are_siblings(area, input_area):
			connect_output(parent)

# Handle input area exited
func _on_input_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Component_cb or parent is Wire_cb:
		disconnect_input(parent)

# Handle output area exited
func _on_output_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Component_cb or parent is Wire_cb:
		disconnect_output(parent)

# Connect input
func connect_input(node: Node) -> void:
	if node == self:  # Prevent self-connections
		return
	if node not in connected_inputs:
		connected_inputs.append(node)
		update_input_point()

# Connect output
func connect_output(node: Node) -> void:
	if node == self:  # Prevent self-connections
		return
	if node not in connected_outputs:
		connected_outputs.append(node)
		if node is Wire_cb:
			node.output_point = output_point
		elif node is Component_cb:
			node.input_point = output_point

# Disconnect input
func disconnect_input(node: Node) -> void:
	if node in connected_inputs:
		connected_inputs.erase(node)
		update_input_point()

# Disconnect output
func disconnect_output(node: Node) -> void:
	if node in connected_outputs:
		connected_outputs.erase(node)

# Update input_point based on connected inputs
func update_input_point() -> void:
	var new_input_point = 0
	for input_node in connected_inputs:
		if input_node is Wire_cb:
			new_input_point = max(new_input_point, input_node.output_point)  # Take the highest value
		elif input_node is Component_cb:
			new_input_point = max(new_input_point, input_node.output_point)  # Take the highest value
	if new_input_point != input_point:
		input_point = new_input_point
		propagate_input_change()

# Propagate input changes to connected outputs
func propagate_input_change() -> void:
	for output_node in connected_outputs:
		if output_node is Wire_cb:
			output_node.output_point = input_point
		elif output_node is Component_cb:
			output_node.input_point = input_point

# Check if two nodes are siblings
func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()
