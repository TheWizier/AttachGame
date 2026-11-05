extends Node

class PlayerInfo:
	var id: int
	var name: String
	func _init(id: int, name: String):
		self.id = id
		self.name = name

var players: Dictionary = {}
var a : Dictionary = {}
signal on_lobby_join(peer_id: int)
signal on_lobby_leave(peer_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called by other multiplayer managers
func join(id: int, name: String):
	print("Adding to my lobby")
	players[id] = PlayerInfo.new(id, name)
	on_lobby_join.emit(id)


func leave(id: int):
	print("Removing from my lobby")
	players.erase(id)
	on_lobby_leave.emit(id)
