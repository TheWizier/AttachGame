extends RefCounted
class_name State2

var name: String
var impl_enter: Callable
var impl_exit: Callable
var impl_update: Callable

func _init(
	name: String,
	enter: Callable = func(): pass,
	exit: Callable = func(): pass,
	update: Callable = func(delta, parent_machine): pass,
) -> void:
	self.name = name
	self.impl_enter = enter
	self.impl_exit = exit
	self.impl_update = update

func enter():
	impl_enter.call()
func exit():
	impl_exit.call()
func update(delta, parent_machine):
	impl_update.call(delta, parent_machine)
