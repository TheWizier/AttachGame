extends Node
class_name StateMachine

var active_state: State
var previous_state: State

var states: Dictionary[String, State] = {}

## StateMachine
## start state will be first element in [param p_states]
func _init(p_states: Array[State]) -> void:
	if p_states.is_empty():
		push_error("states can not be empty")
	for state in p_states:
		states[state.get_name()]=state
	active_state = p_states[0]
	active_state.enter()

func run_state_update(delta: float):
	active_state.update(delta, self)
func run_state_physics_update(delta: float):
	active_state.physics_update(delta, self)

func set_state(new_state_name: String):
	previous_state=active_state
	active_state=states[new_state_name]

	previous_state.exit()
	active_state.enter()
