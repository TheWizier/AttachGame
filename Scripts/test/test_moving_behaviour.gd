extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var speed: int = 300
var cur_time: float = 0
var timespan: float = 2.5
func _process(delta: float) -> void:
	cur_time += delta
	if cur_time >  timespan:
		cur_time = cur_time - timespan
		speed = -speed
	position.x += speed*delta
