class_name PowerSourceComponent_cb extends BaseComponent_cb

#Enums

enum PSUTypeEnum {
	AC, ##Generates an alternating current signal
	DC, ##Generates a continuous current signal
	SQ, ##Generates a current signal that alternates between two fixed signals
	HW, ##Generates a current signal that corresponds to a rectified alternated current signal (Half Wave)
	RAC, ###Generates a current signal that corresponds to a rectified alternated current signal (Full Wave)
	ST ##Generates a current signal that linearly ramps up before sharply dropping back to default value
	= -1
}

#Exports

##Defines the type of power supply
@export var type_of_PSU: PSUTypeEnum

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
