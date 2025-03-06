extends Node

var selected_level: String = ""

var native_font: Font = load("res://files/fonts/TeenyTinyPixls/TeenyTinyPixls-o2zo.ttf")

enum Colorthemes {
	Dark,
	Light
}

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
