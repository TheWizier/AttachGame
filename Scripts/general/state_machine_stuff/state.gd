extends RefCounted
class_name State

var parent_machine: StateMachine
var substates?

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
func input_update(input_event: InputEvent):
	pass
