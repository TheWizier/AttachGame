class_name NetworkIdManager
extends Node

var unique_id_counter = 0

func aquire_unique_id() -> int:
	print("AQUIRE_ID!!!")
	if is_multiplayer_authority():
		unique_id_counter += 1
		return unique_id_counter
	else:
		push_error("ERROR wrong aquire")
		return -1
