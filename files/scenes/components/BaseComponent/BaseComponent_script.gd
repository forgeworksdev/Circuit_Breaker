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

@export var resistance: float
@export var max_current: float
@export var max_voltage: float

##Defines if the component can be erased with the delete tool
@export var can_delete: bool

##Defines if the component is polarized
@export var is_polarized: bool

@export var input_area: Area2D
@export var output_area: Area2D
@export var main_area: Area2D

@export var DraggableComponent: Node

var is_burnt: bool

#Vars

var input_current: float = 0
var input_voltage: float = 0

var output_current: float = 0

var _output_voltage
var output_voltage: float = 0:
	set(new_voltage):
		_output_voltage = new_voltage
		sync_values()
	get:
		return _output_voltage

var connected_components: Array = []

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

#func wire_start_area_entered(area: Area2D):
	#if !are_siblings(wire_start_area, area):
		##area.get_parent().output_voltage = self.input_voltage
		#print("INDEV!")
#
#func wire_middle_area_entered(area: Area2D):
	#if !are_siblings(wire_middle_area, area):
		#print("INDEV!")
#
#func wire_end_area_entered(area: Area2D):
	#if !are_siblings(wire_end_area, area):
		##area.get_parent().input_voltage = self.output_voltage
		#print("INDEV!")

func calculate_values():
	pass

func sync_values():
	for component in connected_components:
		component.set_voltage(self.output_voltage)
		print("Sync-ed wire voltage")

func connect_input_components(area: Area2D):
	if !DraggableComponent.can_drag:
		#if !are_siblings(area, wire_end_area):
			#and area.get_child(0).shape == CircleShape2D:
			var other_node := area.get_parent()
			if other_node not in connected_components:
				connected_components.append(other_node)
				print("Connected a component to Input")

func connect_output_components(area: Area2D):
	if !DraggableComponent.can_drag:
		#if !are_siblings(area, wire_end_area):
			#and area.get_child(0).shape == CircleShape2D:
			var other_node := area.get_parent()
			if other_node not in connected_components:
				connected_components.append(other_node)
				print("Connected a component to output")

func connect_components(area: Area2D):
	if !DraggableComponent.can_drag:
		#if !are_siblings(area, wire_end_area):
			#and area.get_child(0).shape == CircleShape2D:
			var other_node := area.get_parent()
			if other_node not in connected_components:
				connected_components.append(other_node)
				print("Connected a component")
