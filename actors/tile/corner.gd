extends Tile

func can_pass(direction: Rotation) -> bool:
	var rotation: Rotation = tile_rotation

	if direction == Rotation.UP:
		return rotation == Rotation.DOWN or rotation == Rotation.RIGHT
	elif direction == Rotation.RIGHT:
		return rotation == Rotation.LEFT or rotation == Rotation.DOWN
	elif direction == Rotation.DOWN:
		return rotation == Rotation.LEFT or rotation == Rotation.UP
	elif direction == Rotation.LEFT:
		return rotation == Rotation.RIGHT or rotation == Rotation.UP

	return true
