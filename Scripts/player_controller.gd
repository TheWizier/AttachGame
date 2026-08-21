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
