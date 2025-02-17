extends Node2D

#@onready var sub_viewport: SubViewport = $Game/SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#print(str(get_viewport().world_2d))
	#sub_viewport.world_2d = get_viewport().world_2d
	#print(str(get_viewport().world_2d) + "" + str(sub_viewport.get_viewport().world_2d))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _input(event: InputEvent) -> void:
	#$Main/SubViewport.push_input(event)
