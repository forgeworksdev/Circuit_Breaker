class_name DeleteTool_cb extends BaseTool_cb

var object: Area2D
var entered:bool

func _ready():
	pass

func _process(delta: float) -> void:
	super ._process(delta)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and entered == true:
		if object.get_parent().can_delete == true:
			object.get_parent().queue_free()


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	#if area.get_parent() is BaseComponent_cb or area.get_parent() is Wire_cb:
	if area.get_parent() is not BaseTool_cb:
		object = area
		entered = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	object = null
	entered = false
