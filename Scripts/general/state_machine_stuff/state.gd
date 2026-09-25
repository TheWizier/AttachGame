extends RefCounted
class_name State

var parent_machine: StateMachine

func _init(parent_machine: StateMachine):
	self.parent_machine = parent_machine

# Virtual functions
func get_name():
	pass
func enter():
	pass
func exit():
	pass
func update(delta: float):
	pass
func physics_update(delta: float):
	pass
func command_update(input_event: CommandEvent) -> bool:
	return false
# action_name -> target_state_name, only populated when currently valid
# for instance if attack is cancelable after 75% then: before that return {}
# and after return {"action_name": "target_state_name"}
func get_cancel_options() -> Dictionary:
	return {}
