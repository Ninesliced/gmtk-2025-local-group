extends Camera2D
class_name NSCam

var _shake_force: float = 0.0
var _shake_fade : float = 0.0
var _shake_threshold: float = 0.1

func shake(intensity: float = 10.0, fade: float = 5.0, threshold: float = 2.0) -> void:
	_shake_fade = fade
	_shake_force = intensity
	_shake_threshold = threshold

func _process(delta: float) -> void:
	if _shake_force > _shake_threshold:
		_shake_force = lerp(_shake_force, 0.0, delta * _shake_fade)
		print(_shake_force)
		offset = Vector2(
			randf_range(-_shake_force, _shake_force),
			randf_range(-_shake_force, _shake_force)
		)