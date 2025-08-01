extends Tile

func can_pass(direction: Rotation) -> bool:
	var dir_rotation: Rotation = tile_rotation

	if direction == Rotation.UP:
		return dir_rotation == Rotation.LEFT or dir_rotation == Rotation.RIGHT
	elif direction == Rotation.RIGHT:
		return dir_rotation == Rotation.UP or dir_rotation == Rotation.DOWN
	elif direction == Rotation.DOWN:
		return dir_rotation == Rotation.LEFT or dir_rotation == Rotation.RIGHT
	elif direction == Rotation.LEFT:
		return dir_rotation == Rotation.UP or dir_rotation == Rotation.DOWN

	return true
