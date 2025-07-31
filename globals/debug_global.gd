extends Node

func _ready() -> void:
    print("Reloading scene...")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("fast_reload"):
        TransitionManager.reload_scene("square_gradient")