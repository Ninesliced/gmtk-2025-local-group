extends AnimatedSprite2D

func _on_movement_component_on_move(direction:Vector2):
	if direction.x > 0:
		flip_h = false
		play("walk_horizontal")
	elif direction.x < 0:
		flip_h = true
		play("walk_horizontal")
	else:
		play("walk_horizontal")

	pass # Replace with function body.


func _on_movement_component_on_idle():
	play("idle")
	pass # Replace with function body.
