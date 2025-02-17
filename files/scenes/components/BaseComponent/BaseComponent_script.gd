@icon("res://files/sprites/exported/base_comp.png")
class_name BaseComponent_cb extends Node2D

#Enums

enum ComponentTypeEnum {
	ACTIVE, ##Generates voltage and current to achieve the expected result.
	PASSIVE ##Modifies current and voltage to achieve the expected result
	= -1
}

#Exports

##Defines the type of component
@export var type_of_comp: ComponentTypeEnum

##Defines if the component is being powered
@export var is_powered: bool
##Defines if the component can be erased with the delete tool
@export var can_delete: bool
##Defines if the component is polarized
@export var is_polarized: bool

@export_category("Values")
@export var resistance: float
@export var max_current: float
@export var max_voltage: float

@export_category("Collisions")
@export var input_area: Area2D
@export var output_area: Area2D
@export var main_area: Area2D

@export var DraggableComponent: Node

var is_burnt: bool

#Vars

var input_current: float = 0
var input_voltage: float = 0

var _output_current: float = 0.0
var output_current: float:
	set(new_current):
		_output_current = new_current
		sync_values()
	get:
		return _output_current

var _output_voltage: float
var output_voltage: float = 0:
	set(new_voltage):
		_output_voltage = new_voltage
		sync_values()
	get:
		return _output_voltage

var connected_input_components: Array = []
var connected_output_components: Array = []

var is_connected_to_PSU: bool = false

func _ready() -> void:
	input_area.connect("area_entered", input_area_entered)
	#input_area.connect("area_exited", input_area_exited)
	output_area.connect("area_entered", output_area_entered)
	#output_area.connect("area_exited", output_area_exited)
	#input_area.connect("area_exited", input_area_exited)

func _process(delta: float) -> void:
	sync_values()

func input_area_entered(area: Area2D):
	if !are_siblings(input_area, area):
		#area.get_parent().output_voltage = self.input_voltage
		connect_input_components(area)

func output_area_entered(area: Area2D):
	if !are_siblings(output_area, area):
		connect_output_components(area)

#func input_area_exited(area: Area2D):
	#if !are_siblings(input_area, area):
		##area.get_parent().output_voltage = self.input_voltage
		#print("INDEV!")

#func output_area_exited(area: Area2D):
	#if !are_siblings(output_area, area):
		#disconnect_output_components(area)

func get_voltage() -> float:
	#print(str(voltage))
	return output_voltage

func get_current() -> float:
	return output_current
#
#func get_current() -> float:
	##print(str(current))
	#return current
#
#func set_voltage(new_voltage: float = 0) -> void:
	#if voltage != new_voltage:
		#voltage = new_voltage
#
#func set_current(new_current: float = 0):
	#if current != new_current:
		#current = new_current

func calculate_values(voltage: float, current: float, resistance: float):
	pass

#func sync_values() -> void:
	#for comp in connected_output_components:
		#comp.set_voltage(self.output_voltage)
		#comp.set_current(self.output_current)
		##print("Sync-ed wire voltage")
func sync_values() -> void:
	if self.type_of_comp == ComponentTypeEnum.ACTIVE:
		return
	for comp in connected_input_components:
		if self.is_connected_to_PSU:
			break
		else:
			self.input_voltage = comp.get_voltage()
			self.input_current = comp.get_current()

	for comp in connected_output_components:
		if comp.is_connected_to_PSU:
			break
		else:
			comp.set_voltage(self.output_voltage)
			comp.set_current(self.output_current)

func connect_input_components(area: Area2D) -> void:
	#if !can_drag:
	if (area.get_parent() is BaseComponent_cb or area.get_parent() is Wire_cb):
		if !are_siblings(area, output_area):
			#and area.get_child(0).shape == CircleShape2D:
			var other_node := area.get_parent()
			if other_node not in connected_input_components:
				connected_input_components.append(other_node)
				#print("Connected a wire")

func connect_output_components(area: Area2D):
	#if !can_drag:
	if (area.get_parent() is BaseComponent_cb or area.get_parent() is Wire_cb):
		if !are_siblings(area, output_area):
			#and area.get_child(0).shape == CircleShape2D:
			var other_node := area.get_parent()
			if other_node not in connected_output_components:
				connected_output_components.append(other_node)
				#print("Connected a wire")

func are_siblings(node_a, node_b) -> bool:
	return node_a.get_parent() == node_b.get_parent()

#func connect_components(area: Area2D):
	#if !DraggableComponent.can_drag:
		##if !are_siblings(area, input_area):
			##and area.get_child(0).shape == CircleShape2D:
			#var other_node := area.get_parent()
			#if other_node not in connected_components:
				#connected_components.append(other_node)
				#print("Connected a component")
