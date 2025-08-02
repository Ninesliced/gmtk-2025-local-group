extends Node

var is_debug: bool = false
var no_clip: bool = false

func _ready() -> void:
    print("Reloading scene...")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("fast_reload"):
        TransitionManager.reload_scene("square_gradient")
    if event.is_action_pressed("debug") and !OS.has_feature("labite"):
        is_debug = !is_debug
        