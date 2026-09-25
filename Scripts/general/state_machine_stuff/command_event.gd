extends RefCounted
class_name CommandEvent

enum Type { PRESSED, RELEASED }

var action: String
var type: Type
var tick: int # the tick this command was issued/received on

func _init(p_action: String, p_type: Type, p_tick: int):
	action = p_action
	type = p_type
	tick = p_tick

func is_action(action: String) -> bool:
	return self.action == action

func is_pressed() -> bool:
	return type == Type.PRESSED