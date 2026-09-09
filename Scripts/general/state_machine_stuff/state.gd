extends RefCounted
class_name State

# Virtual functions
func get_name():
	pass
func enter():
	pass
func exit():
	pass
func update(delta, parent_machine):
	pass
