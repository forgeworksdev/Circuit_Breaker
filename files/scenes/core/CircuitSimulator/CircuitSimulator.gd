class_name CircuitSimulator_cb
extends Node

var circuit: Array = []

var series_resistances: Array = []
var paralel_resistances: Array = []

var equivalent_resistance : float = 0.0
var circuit_voltage: float = 0.0
var total_current: float = 0.0

func _ready() -> void:
	for component in self.get_children():
		circuit.append(component)
	print(str(circuit))
	get_circuit_voltage()

func get_circuit_voltage():
	for comp in circuit:
		if comp.is_PSC:
			circuit_voltage = comp.voltage

## Determines if two components are in series or paralel
func check_configuration(component_a: Component_cb, component_b: Component_cb) -> String:
	if not component_a or not component_b:
		return "invalid"
	if component_a.input_point == 0 or component_b.input_point == 0:
		return "invalid"
	if (component_a.input_point == component_b.input_point) and (component_a.output_point == component_b.output_point):
		return "parallel"
	if (component_a.output_point == component_b.input_point) or (component_b.output_point == component_a.input_point):
		return "series"
	return "unconnected"

func calculate_missing_component_variable(component: Node, voltage: float = 0, current: float = 0, resistance: float = 0):
	var missing_count = int(voltage == 0) + int(current == 0) + int(resistance == 0)
	if missing_count > 1:
		print("Error: Not enough values")
		return
	if voltage == 0:
		voltage = current * resistance
		return voltage
	elif current == 0:
		current = voltage / resistance
		return current
	elif resistance == 0:
		resistance = voltage / current
		return resistance

func calculate_equivalent_resistance(resistances: Array, is_series: bool = true):
	if is_series:
		for resistor in resistances:
			equivalent_resistance += resistor.resistance
	else:
		for resistor in resistances:
			equivalent_resistance += 1.0 / resistor.resistance
		if equivalent_resistance != 0:
			equivalent_resistance = 1.0 / equivalent_resistance
		else:
			equivalent_resistance = INF

func calculate_voltage_drop(resistor: Node, total_resistance: float) -> float:
	return circuit_voltage * (resistor.resistance / equivalent_resistance)

func calculate_total_current():
	if equivalent_resistance == 0:
		print("Error: Short circuit")
		return 0
	if circuit_voltage == 0:
		print("Error: No voltage")
		return 0
	total_current = circuit_voltage / equivalent_resistance
	#return total_current
