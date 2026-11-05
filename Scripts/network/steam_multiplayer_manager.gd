extends Node

signal host_created()

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer: SteamMultiplayerPeer

func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)
	Steam.lobby_chat_update.connect(on_lobby_chat_update)


func _process(delta: float) -> void:
	# Must be called every frame
	Steam.run_callbacks()


func host_lobby() -> void:
	# Will cause the "lobby_created" and "lobby_joined" signals to emit
	print("HOST LOBBY STEAM")
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS)


# Called after creating a lobby locally
func on_lobby_created(connect: int, lobby_id: int) -> void:
	# We created the lobby, so we act as server host
	if connect == Steam.RESULT_OK:
		print("ON LOBBY CREATED")
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()


# Called when joining a lobby (after creating the lobby or joining a friend)
func on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("ON LOBBY JOIN")
		# If we created the lobby, we are already hosting, so we should not create a new client peer
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer


# Called when attempting to join from the Steam interface
func on_join_requested(lobby_id: int, steam_id: int) -> void:
	# Will cause the "lobby_joined" signal to emit
	print("REQUEST JOIN")
	Steam.joinLobby(lobby_id)


# Called when someone joins, leaves, disconnects, or is kicked/banned
func on_lobby_chat_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	var player_name: String = Steam.getFriendPersonaName(changed_id)

	match chat_state:
		Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
			print("%s joined the lobby" % player_name)
			MultiplayerLobby.join(changed_id, player_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
			print("%s left the lobby" % player_name)
			MultiplayerLobby.leave(changed_id)
		Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED:
			print("%s disconnected" % player_name)
			MultiplayerLobby.leave(changed_id)
		Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
			print("%s was kicked by %s" % [player_name, Steam.getFriendPersonaName(making_change_id)])
			MultiplayerLobby.leave(changed_id)
		Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
			print("%s was banned by %s" % [player_name, Steam.getFriendPersonaName(making_change_id)])
			MultiplayerLobby.leave(changed_id)
