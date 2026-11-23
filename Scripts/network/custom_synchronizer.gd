class_name CustomSynchronizer
extends PropertyBinder

var id: int

var multiplayer_orchestrator: MultiplayerOrchestrator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	multiplayer_orchestrator = get_tree().current_scene.find_child("MultiplayerOrchestrator")
	multiplayer_orchestrator.register_custom_synchronizer(self)
