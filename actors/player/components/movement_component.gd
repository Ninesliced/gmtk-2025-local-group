extends Node

@export var speed : float = 300
@export var acceleration : float = 3000
@export var deceleration : float = 3000
var parent : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if parent == null:
		var new_parent = get_parent()
		if new_parent is CharacterBody2D:
			parent = new_parent
		else:
			assert(false, "MovementComponent must be a child of a CharacterBody2D node.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	direction = direction.normalized()
	if direction.x **2 + direction.y **2 > 0.4:
		GameGlobal.is_game_have_start = true
	
	parent.velocity.x = move_toward(parent.velocity.x, direction.x * speed, acceleration * delta)
	parent.velocity.y = move_toward(parent.velocity.y, direction.y * speed, acceleration * delta)
	parent.move_and_slide()
	pass
