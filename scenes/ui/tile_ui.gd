extends Node2D

class_name TileUi

enum Rotation {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

@onready var outline: Node2D = %Outline
@onready var sprite: AnimatedSprite2D = %Sprite

@onready var seasons: Array[String] = ["spring","summer","fall","winter"]
var outline_color: Color            = Color(1, 1, 1, 1)
var outline_tween: Tween            = null

@export var outline_min: float = 0.1
@export var outline_max: float = 0.5

@export var sound_action: AudioStreamPlayer2D

@export var rotation_speed: float = 0.2
@export var rotation_sound_effect: AudioStreamPlayer2D
@export var idle_rotation_sound_effect: AudioStreamPlayer2D

@export var is_changeable := true
@export var tile_rotation : Rotation = Rotation.UP :
	set(new_rotation):
		if rotation_sound_effect:
			rotation_sound_effect.pitch_scale = randf_range(0.6, 1.0)
			rotation_sound_effect.play()

		if is_inside_tree() && get_tree():
			rotate_animated(new_rotation)

		tile_rotation = new_rotation % 4

@export var is_action_spawnable: bool = true
@export_range(0, 1, 0.01) var chance_action_spawn: float = 0.1

var is_hover : bool = false

func rotate_clock() -> void:
	tile_clicked(1)

func rotate_counter_clock() -> void:
	tile_clicked(-1)

func _ready():
	sprite.speed_scale = 0
	var frames = sprite.sprite_frames.get_frame_count(sprite.animation)
	sprite.frame = randi() % frames
	tile_rotation = randi() % 4

	if is_action_spawnable:
		if GameGlobal.rng.randf() < chance_action_spawn:
			var action_load: PackedScene = load("res://actors/action/action.tscn")
			var action = action_load.instantiate()
			action.choose_an_random_action()
			action.position = Vector2i(8,8)
			%ActionHolder.add_child(action)

func _on_area_mouse_entered() -> void:
	tile_hovered()
	is_hover = true


func _on_area_mouse_exited() -> void:
	tile_unhovered()
	is_hover = false


func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			return
		
		if event.button_index == 1:
			rotate_clock()
		if event.button_index == 2:
			rotate_counter_clock()

func tile_clicked(way: int) -> void:
	tile_rotation = (tile_rotation + way) % 4

	if tile_rotation < 0:
		tile_rotation += 4

func tile_hovered() -> void:
	show_outline()

func tile_unhovered() -> void:
	hide_outline()


func show_outline() -> void:
	outline.visible = true
	low_visibility_outline()

func hide_outline() -> void:
	outline.visible = false
	if outline_tween:
		outline_tween.stop()

func low_visibility_outline() -> void:
	if not outline.visible:
		return

	var color := outline.modulate
	outline_tween = create_tween()
	outline_tween.tween_property(outline, "modulate", Color(color.r, color.g, color.b, 0.2), 0.6)
	outline_tween.set_ease(Tween.EASE_IN_OUT)
	outline_tween.tween_callback(high_visibility_outline)

func high_visibility_outline() -> void:
	if not outline.visible:
		return

	var color := outline.modulate
	outline_tween = create_tween()
	outline_tween.tween_property(outline, "modulate", Color(color.r, color.g, color.b, 0.5), 0.6)
	outline_tween.set_ease(Tween.EASE_IN_OUT)
	outline_tween.tween_callback(low_visibility_outline)

func rotate_animated(new_rotation: int) -> void:
	# print(new_rotation)
	# print(%Sprite.rotation, " vs ", PI / 2 * new_rotation)
	if abs(%Sprite.rotation - PI / 2 * new_rotation) > PI:
		if %Sprite.rotation < PI / 2 * new_rotation:
			%Sprite.rotation += PI * 2
		else:
			%Sprite.rotation -= PI * 2

	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite, "rotation", PI / 2 * new_rotation, rotation_speed)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

func play_sound() -> void:
	if not sound_action:
		print("no sound action set")
		return
	# print("Playing sound")
	sound_action.play()
