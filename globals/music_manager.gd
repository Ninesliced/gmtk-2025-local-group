extends Node2D


# Initially calfed for the main menu stuff
@export var calfed := true :
	set(value):
		if value == calfed:
			return

		if value:
			%AnimationPlayer.play("normal_to_calfed")
		else:
			%AnimationPlayer.play("calfed_to_normal")

		calfed = value


func _ready() -> void:
	# FIXME: Godot is broken again with volumes
	%CalfedMainMusic.play()
	%CalfedMainMusic.volume_db = -15.0
	%RegularMainMusic.play()
	%RegularMainMusic.volume_db = -80.0
