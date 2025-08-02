extends CanvasLayer
@onready var animation_player = $AnimationPlayer
func change_scene(packed_scene: PackedScene, start="fade", end=null, speed=2.5) -> void:
	var old_speed = animation_player.speed_scale
	animation_player.speed_scale = speed
	animation_player.play(start)
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(packed_scene)

	await get_tree().process_frame
	if animation_player.is_playing():
		await animation_player.animation_finished

	if end:
		animation_player.play(end)
	else:
		animation_player.play_backwards(start)
	await animation_player.animation_finished
	animation_player.speed_scale = old_speed


func reload_scene(start="fade", end=null) -> void:
	var current_scene = get_tree().current_scene
	if current_scene:	
		var packed_scene = current_scene.scene_file_path
		var packed_scene_resource = load(packed_scene)
		if packed_scene_resource:
			change_scene(packed_scene_resource, start, end)
