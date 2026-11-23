class_name AttachCharacter
extends CharacterBody2D

@export var relative_position: Vector2
var attached_to: Node2D
@export var attached_to_id: int # For multiplayer sync

func _init() -> void:
	attached_to = get_tree().current_scene
	relative_position = global_position
