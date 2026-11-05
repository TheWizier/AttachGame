extends Control

@onready var host_steam_button = $HostSteamButton
@onready var join_enet_button = $JoinENetButton
@onready var host_enet_button = $HostENetButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	host_steam_button.pressed.connect(_on_host_steam_pressed)
	join_enet_button.pressed.connect(_on_join_enet_pressed)
	host_enet_button.pressed.connect(_on_host_enet_pressed)

func _on_host_steam_pressed():
	SteamMultiplayerManager.host_lobby()

func _on_join_enet_pressed():
	ENetMultiplayerManager.join_lobby()

func _on_host_enet_pressed():
	ENetMultiplayerManager.host_lobby()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
