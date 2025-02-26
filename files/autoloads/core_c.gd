extends Node

var global_output_point_counter: int = 1  # Start from 1

func get_unique_output_point() -> int:
	var unique_point = global_output_point_counter
	global_output_point_counter += 1
	return unique_point
