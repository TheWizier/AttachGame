extends Node
class_name StateMachine

var active_state: State
var previous_state: State

var states: Array[State] = []

#@onready var parent = get_parent()

## StateMachine
## start state will be first element in [param p_states]
func _init(p_states: Array[State]) -> void:
	if p_states.is_empty():
		push_error("states can not be empty")
	states = p_states
	active_state = states[0]

func run_state_update(delta: float):
	active_state.update(delta, self)

func set_state(new_state: State):
	previous_state=active_state
	active_state=new_state
	
	previous_state.exit()
	new_state.enter()
