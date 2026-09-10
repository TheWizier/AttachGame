extends RefCounted
class_name State

# Virtual functions
func get_name():
	pass
func enter():
	pass
func exit():
	pass
func update(delta: float, parent_machine: StateMachine):
	pass
func physics_update(delta: float, parent_machine: StateMachine):
	pass