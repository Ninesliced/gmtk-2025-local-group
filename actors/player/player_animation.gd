extends AnimatedSprite2D

func _on_movement_component_on_move(direction:Vector2):
    if direction == Vector2.ZERO:
        play("idle")
        return
    if direction.x > 0:
        flip_h = false
        play("walk_horizontal")
    if direction.x < 0:
        flip_h = true
        play("walk_horizontal")
    pass # Replace with function body.
