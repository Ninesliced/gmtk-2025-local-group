extends Spike

func can_pass(direction: Rotation) -> bool:
	var dir_rotation: Rotation = tile_rotation

	if direction == Rotation.UP:
		return dir_rotation != Rotation.UP
	elif direction == Rotation.RIGHT:
		return dir_rotation != Rotation.RIGHT
	elif direction == Rotation.DOWN:
		return dir_rotation != Rotation.DOWN
	elif direction == Rotation.LEFT:
		return dir_rotation != Rotation.LEFT

	return true
