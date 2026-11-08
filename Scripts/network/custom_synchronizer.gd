class_name CustomSynchronizer
extends Node

var id: int
var data: Dictionary

@onready var multiplayer_orchestrator: MultiplayerOrchestrator = $MultiplayerOrchestrator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_orchestrator.register_custom_synchronizer(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
