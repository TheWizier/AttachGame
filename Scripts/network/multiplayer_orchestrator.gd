class_name MultiplayerOrchestrator
extends Node

# Dict peer->sync->dict of obj data
var peer_to_data: Dictionary = {}

# var id_to_synchronizer: Dictionary = {}
var synchronizers: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	network_update()

func network_update():
	for synchronizer: CustomSynchronizer in synchronizers:
		if synchronizer.is_multiplayer_authority():
			send_my_data(synchronizer)
	
func register_custom_synchronizer(synchronizer: CustomSynchronizer):
	synchronizers.append(synchronizer)

func send_my_data(synchronizer: CustomSynchronizer):
	synchronize.rpc(synchronizer.id, synchronizer.data)

@rpc("any_peer", "call_remote", "unreliable")
func synchronize(id: int, data: Dictionary):
	for synchronizer in synchronizers:
		if(synchronizer.id == id):
			synchronizer.recieve_data(data)
			break
