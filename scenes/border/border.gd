extends Node2D

@export var speed : float = 10

func _physics_process(delta):
    global_position.x += delta * speed