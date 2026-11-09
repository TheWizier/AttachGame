extends MultiplayerSpawner

var parent_node: Node = self
var player_scene: PackedScene = preload("res://Scenes/player.tscn")
var orchestrator: MultiplayerOrchestrator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orchestrator = get_tree().current_scene.find_child("MultiplayerOrchestrator")
	self.spawn_function = _spawn_player # TODO: can we just override?
	MultiplayerLobby.on_lobby_join.connect(on_lobby_join)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_lobby_join(peer_id: int):
	print("SPAWNER on lobby join")
	if is_multiplayer_authority():
		spawn(
			{
				"peer_id": peer_id,
				"unique_id": orchestrator.aquire_unique_id()
			}
		)

func _spawn_player(data: Dictionary):
	return spawn_entity(player_scene, data)

# TODO: Move so that it is accessible to all spawners
func spawn_entity(entity_scene: PackedScene, data: Dictionary):
	var entity_node: Node = entity_scene.instantiate()
	entity_node.set_multiplayer_authority(data.peer_id)
	var synchronizer: CustomSynchronizer = entity_node.find_child("CustomSynchronizer")
	synchronizer.id = data.unique_id
	return entity_node
