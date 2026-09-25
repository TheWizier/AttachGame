extends RefCounted
class_name StateMachine

var current_state: State
var previous_state: State
var current_tick: int = 0


var states: Dictionary[String, State] = {}
# TODO what if state sets itself as active so:
# TODO statemachine.states.mystate.activate(params)?
# a bit tricky to get nice

## StateMachine
## start state will be first element in [param p_states]
func set_states(p_states: Array[State]) -> void:
	if p_states.is_empty():
		push_error("states can not be empty")
	for state in p_states:
		states[state.get_name()]=state
	current_state = p_states[0]
	current_state.enter()

func run_state_update(delta: float):
	current_state.update(delta)
	
func run_state_physics_update(delta: float):
	current_state.physics_update(delta)
	current_tick += 1
	
func run_state_command_update(command_event: CommandEvent) -> bool:
	return current_state.command_update(command_event)


func set_state(new_state_name: String):
	previous_state=current_state
	current_state=states[new_state_name]

	previous_state.exit()
	current_state.enter()
