extends Node

@export var wave_range: float = 1.0
@export var wave_speed: float = 10.0

@export var target: Sprite2D
var num_delta: float = 0.0
func _ready():
	pass

func _process(delta: float) -> void:
	num_delta += delta
	self.target.offset.y = -wave_range*0.5 + wave_range * sin(num_delta * wave_speed)
	
	
	
