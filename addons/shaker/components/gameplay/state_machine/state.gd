extends Node
class_name State

var entity : Node :
	set(value):
		entity = value
		on_entity_set()

signal state_finished
signal state_enter

## Called every time the entity is set.
func on_entity_set() -> void:
	pass

## Called when entering the state.
func enter() -> void:
	pass

func process(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass

## Called when exiting the state.
func exit() -> void:
	pass

## Change the state of the state machine to a new state.
func change_state(new_state_name: String) -> void:
	state_finished.emit(self, new_state_name)