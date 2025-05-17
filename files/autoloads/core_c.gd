extends Node

var selected_level: String = ""

var native_font: Font = load("res://files/fonts/TeenyTinyPixls/TeenyTinyPixls-o2zo.ttf")

enum Colorthemes {
	Dark,
	Light
}

class IDGenerator:
	var _next_id: int = 1  # Start from 1, reserve 0 for special cases

	func get_id():
		return _next_id

	func get_next_id() -> int:
		var id = _next_id
		_next_id += 1
		return id

	func reset_id():
		_next_id = 1

	func generate_uuid() -> String:
		var uuid = ""
		for i in range(16):
			uuid += "%02x" % (randi() % 256)
			if i in [3, 5, 7, 9]:
				uuid += "-"
		return uuid


	func reset():
		_next_id = 1

var selected_theme: Colorthemes

var global_output_point_counter: int = 1



func get_unique_output_point() -> int:
	var unique_point = global_output_point_counter
	global_output_point_counter += 1
	return unique_point

func switch_theme_status() -> void:
	if selected_theme == Colorthemes.Light:
		selected_theme = Colorthemes.Dark
	elif selected_theme == Colorthemes.Dark:
		selected_theme = Colorthemes.Light

func set_current_level(Level:String) -> void:
	selected_level = Level if Level != "" else ""

var levels: Dictionary[String, Dictionary] = {
	"CraneLevel": {
		"UID": "uid://b1ie126sbrpq",
		"Path": "res://files/scenes/Levels/CraneLevel/CraneLevel.scn"
	},

	"RoboarmeLevel": {
		"UID": "uid://b1ie126sbrpq",
		"Path": "res://files/scenes/Levels/CraneLevel/CraneLevel.scn"
	},

	"IndustrialComputerLevel": {
		"UID": "uid://b1ie126sbrpq",
		"Path": "res://files/scenes/Levels/CraneLevel/CraneLevel.scn"
	}

}
