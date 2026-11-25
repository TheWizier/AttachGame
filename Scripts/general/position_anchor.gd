class_name PositionAnchor
extends Node2D

const ANCHOR_GROUP := &"position_anchors"

var network_id_manager: NetworkIdManager
@export var net_id: int = -1 # NOTE Must be synchronized

signal received_attachment(other: Node2D)
signal lost_attachment(other: Node2D)

func _ready() -> void:
	add_to_group(ANCHOR_GROUP)
	if multiplayer.is_server():
		network_id_manager = get_tree().current_scene.find_child("NetworkIdManager")
		net_id = network_id_manager.aquire_unique_id()

func receive_attachment(other: Node2D): # TODO Now receiver is responsible for sound and visual effects
	received_attachment.emit(other)
func lose_attachment(other: Node2D):
	lost_attachment.emit(other)
