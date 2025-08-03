extends AnimatedSprite2D

var entered = false
func _on_area_2d_mouse_entered():
	if not entered:
		entered = true
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseButton and entered:
		if event.button_index == MOUSE_BUTTON_LEFT:
			queue_free()