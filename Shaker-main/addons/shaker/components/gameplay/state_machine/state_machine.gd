extends Node2D
class_name StateMachine

@export var initial_state : State
@export var entity : Node

var states : Dictionary = {}
var current_state : State

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.entity = entity

            child.state_finished.connect(on_state_transition)

    if initial_state:
        current_state = initial_state
        current_state.enter()
    else:
        _sm_print("No initial state set, please add one in the inspector")


func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_process(delta)

func on_state_transition(state: State, new_state_name: String) -> void:
    if state != current_state:
        return

    if states.has(new_state_name):
        current_state = states[state.name.to_lower()]
    var new_state = states.get(new_state_name.to_lower())

    if !new_state:
        _sm_print("State '" + new_state_name + "' not found in the state machine.")
        return

    if state:
        state.exit()
    new_state.enter()
    new_state.state_enter.emit()
    current_state = new_state



func _sm_print(message: String) -> void:
    message = "[StateMachine]: " + message