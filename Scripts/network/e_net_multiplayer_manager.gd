extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var PORT = 9999
var MAX_CONNECTIONS = 4
var DEFAULT_SERVER_IP = "127.0.0.1"#"localhost"

func join_lobby(address = ""):
	print("join_lobby")
	if address.is_empty():
		print("Using default: ", DEFAULT_SERVER_IP)
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		print("ERROR join lobby")
		print(error)
		return error
	multiplayer.multiplayer_peer = peer

func host_lobby():
	print("host_lobby")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		print("ERROR host lobby")
		return error
	multiplayer.multiplayer_peer = peer

	# players[1] = player_info
	# player_connected.emit(1, player_info)

func _on_player_connected(id: int):
	print("ENET player connected")
	var player_name = "NONAME" # TODO: add names?
	MultiplayerLobby.join(id, player_name)
func _on_player_disconnected(id: int):
	print("ENET player disconnected")
	MultiplayerLobby.leave(id)
func _on_connected_ok():
	print("ENET connected ok")
func _on_connected_fail():
	print("ENET connected fail")
func _on_server_disconnected():
	print("ENET server disconnected")
