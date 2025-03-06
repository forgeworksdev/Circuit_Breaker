class_name Level_cb extends Node2D

@export var level_objective: String

func get_level_objective():
	print("get_level_objective was called!")
	if not level_objective.is_empty():
		return level_objective
	else:
		print("Error: No Level Objective specified")
