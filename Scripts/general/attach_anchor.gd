extends Area2D
class_name AttachAnchor

signal received_attachment(other: Node2D)
signal lost_attachment(other: Node2D)
signal kicked(other: Node2D, direction: Vector2)

func receive_attachment(other: Node2D): # TODO Now receiver is responsible for sound and visual effects
	received_attachment.emit(other)
func lose_attachment(other: Node2D):
	lost_attachment.emit(other)
func receive_kick(other: Node2D, direction: Vector2):
	kicked.emit(other, direction)
