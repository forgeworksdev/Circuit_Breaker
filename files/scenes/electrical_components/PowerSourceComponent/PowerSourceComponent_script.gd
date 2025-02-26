@icon("res://files/sprites/exported/PS_CC.png") class_name PowerSourceComponent_cb extends Component_cb

#Enums

enum PSCTypeEnum {
	AC, ##Generates an alternating current signal
	DC, ##Generates a continuous current signal
	SQ, ##Generates a current signal that alternates between two fixed signals
	ST ##Generates a current signal that linearly ramps up before sharply dropping back to default value
	#= -1
}

#Exports

##Defines the type of power supply
@export var type_of_PSU: PSCTypeEnum

func _ready() -> void:
	super()
	input_point = randi_range(1, 1000)

	match PSCTypeEnum:
		PSCTypeEnum.AC:
			pass
		PSCTypeEnum.DC:
			pass
		PSCTypeEnum.SQ:
			pass
		PSCTypeEnum.ST:
			pass
#
#func _process(delta: float) -> void:
	#super ._process(delta)
