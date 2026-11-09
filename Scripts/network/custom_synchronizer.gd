class_name CustomSynchronizer
extends PropertyAccessor

var id: int

var multiplayer_orchestrator: MultiplayerOrchestrator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_orchestrator = get_tree().current_scene.find_child("MultiplayerOrchestrator")
	multiplayer_orchestrator.register_custom_synchronizer(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
