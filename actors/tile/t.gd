extends Tile

func can_pass(direction: Rotation) -> bool:
	var rotation: Rotation = tile_rotation
	
	if direction == Rotation.UP:
		return rotation != Rotation.UP
	elif direction == Rotation.RIGHT:
		return rotation != Rotation.RIGHT
	elif direction == Rotation.DOWN:
		return rotation != Rotation.DOWN
	elif direction == Rotation.LEFT:
		return rotation != Rotation.LEFT
	
	return true
