extends PositionAnchor
class_name AttachAnchor

signal kicked(other: Node2D, direction: Vector2)

func receive_kick(other: Node2D, direction: Vector2):
	kicked.emit(other, direction)
