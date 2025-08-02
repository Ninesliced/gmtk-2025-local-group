extends Node2D

@export var speed : float = 10

func _physics_process(delta):
	if !GameGlobal.is_game_have_start:
		return
	if !GameGlobal.camera:
		return
	var camera_size = GameGlobal.camera.get_viewport().get_visible_rect().size
	var distance_a_la_camera = (GameGlobal.camera.global_position.x-camera_size.x/2) - global_position.x
	if distance_a_la_camera > 0:
		global_position.x += max(delta * speed, distance_a_la_camera*delta*3)
	else:
		global_position.x += delta * speed
		
	# print(((GameGlobal.camera.global_position.x-GameGlobal.camera.get_viewport().get_visible_rect().size.x/2) - global_position.x)*delta*3)
	# global_position.x += delta * speed


func _on_tile_mover_area_area_entered(area: Area2D) -> void:
	var selected_actor = area.get_parent()
	if (selected_actor is not Tile) and (selected_actor is not Enemy):
		return
	# On bouge vers la droite
	if !GameGlobal.map:
		return
	var espacement = GameGlobal.map.grid_size.x * GameGlobal.map.tile_size.x
	selected_actor.position.x += espacement
