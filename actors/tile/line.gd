extends Tile

func can_pass(direction: Rotation) -> bool:
	var rotation: Rotation = tile_rotation

	if direction == Rotation.UP:
		return rotation == Rotation.LEFT or rotation == Rotation.RIGHT
	elif direction == Rotation.RIGHT:
		return rotation == Rotation.UP or rotation == Rotation.DOWN
	elif direction == Rotation.DOWN:
		return rotation == Rotation.LEFT or rotation == Rotation.RIGHT
	elif direction == Rotation.LEFT:
		return rotation == Rotation.UP or rotation == Rotation.DOWN

	return true
