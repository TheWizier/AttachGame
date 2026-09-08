extends RefCounted
class_name State

var actor: Node

func _init(actor: Node):
	self.actor = actor
# Virtual functions
func get_name():
	pass
func enter():
	pass
func exit():
	pass
func update(delta, parent_machine):
	pass
