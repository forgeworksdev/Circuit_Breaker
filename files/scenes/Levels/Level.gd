class_name Level_cb extends Node2D

@export var level_objective: String

##Total time for completion
@export var total_available_TOC: float
##Perfect Time of completion
@export var perfect_TOC: float
##two stars Time of completion. Anything under this will be one star
@export var medium_TOC: float

var LevelTimer: Timer = Timer.new()

func _init():
	LevelTimer.name = "LevelTimer"
	LevelTimer.wait_time = perfect_TOC
	add_child(LevelTimer)

func get_level_objective():
	print("get_level_objective was called!")
	if not level_objective.is_empty():
		return level_objective
	else:
		print("Error: No Level Objective specified")
