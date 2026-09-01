extends Node

var player_state_machine: StateMachine

func _ready() -> void:
	pass
	var states: Array[State] = [
		NormalState.new(),
		AttachedState.new()
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


class AttachedState extends State:
	func update(delta, parent_machine):
		pass
		# TODO somehow get pos of attach node
		# lerp to position around it that rotates
		# (will break when things move so just lerp to starting position and then
		#  trasition to attached from perhaps attaching state. Maybe we need detatching state as well?
		# (or just rotate around by rotating the attach node and counter rotating us?
		# that means we get pushed back when the blade connects


# TODO Next is input handling
# I want a short buffer so that certain inputs gets queued if I want
#
