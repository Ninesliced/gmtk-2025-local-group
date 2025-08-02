extends Tile

class_name Spike

func transform_to_another_type(new_tile: PackedScene, play_animation: bool = true) -> Tile:
	var tile_path = new_tile.resource_path
	var tile_name : String = tile_path.get_file().get_basename()
	
	match tile_name:
		"full":
			new_tile = load("res://actors/tile/spike/full_spike.tscn")
		"four":
			new_tile = load("res://actors/tile/spike/four_spike.tscn")
		"line":
			new_tile = load("res://actors/tile/spike/line_spike.tscn")
		"corner":
			new_tile = load("res://actors/tile/spike/corner_spike.tscn")
		"t":
			new_tile = load("res://actors/tile/spike/t_spike.tscn")
	
	return super.transform_to_another_type(new_tile, play_animation)
