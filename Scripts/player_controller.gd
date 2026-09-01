extends Node

var player_state_machine: StateMachine

func _ready() -> void:
	pass
	var states: Array[State] = [
		NormalState.new(),
		AttackState.new()
	]
	player_state_machine = StateMachine.new(states)

func _physics_process(delta: float) -> void:
	player_state_machine.run_state_update(delta)
	
func _process(delta: float) -> void:
	pass

# State definitions #

class NormalState extends State:
	#var states: Array[State] = [
		## States that run independently of the parent state machine
	#]
	#var arms_state_machine = StateMachine.new(states)
	func enter():
		pass
	func exit():
		pass
	func update(delta, parent):
		
		pass


class AttackState extends State:
	func update(delta, parent_machine):
		pass


# TODO Next is input handling
# I want a short buffer so that certain inputs gets queued if I want
#
