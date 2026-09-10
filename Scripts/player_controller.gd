extends CharacterBody2D
class_name PlayerController

var player_state_machine: StateMachine
var scene_root: Node
var active_anchor: Node2D

var attach_distance: float = 100

@onready var attach_hitbox: Area2D = $Hitbox 
@onready var attach_ray: RayCast2D = $RayCast2D

func _ready() -> void:
	self.scene_root = get_tree().current_scene
	var states: Array[State] = [
		NormalState.new(self),
		AttachingState.new(self),
		AttachedState.new(self),
		DetachingState.new(self)
	]
	player_state_machine = StateMachine.new(states)

func _physics_process(delta: float) -> void:
	player_state_machine.run_state_physics_update(delta)

func _process(delta: float) -> void:
	player_state_machine.run_state_update(delta)

# State definitions #

class PlayerState extends State:
	var player: PlayerController
	func _init(player: PlayerController):
		self.player = player


class NormalState extends PlayerState:
	var movement_speed: float = 500
	#var states: Array[State] = [
		## States that run independently of the parent state machine
	#]
	func get_name():
		return "normal"
	#var arms_state_machine = StateMachine.new(states)
	func enter():
		print("Normal")
		pass

	func update(delta, player_state_machine):
		if Input.is_action_just_pressed("special"):
			if player.attach_ray.is_colliding():
				player.active_anchor = player.attach_ray.get_collider()
				player_state_machine.set_state("attaching")

	func physics_update(delta: float, parent_machine: StateMachine):
		var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
		player.velocity = input_direction * movement_speed
		player.move_and_slide()


class AttachingState extends PlayerState:
	var total_duration: float = 0.2
	var current_time: float = 0.0
	var start_position: Vector2 = Vector2(0,0)
	var target_position: Vector2 = Vector2(0,0)

	func get_name():
		return "attaching"

	func enter():
		print("AttaCHING")
		current_time=0
		player.reparent(player.active_anchor)
		start_position = player.position
		target_position = player.position.normalized()*player.attach_distance
	
	func update(delta, parent_machine):
		# Lerp into position
		current_time+=delta
		current_time=min(total_duration, current_time)
		player.position=lerp(start_position, target_position, current_time/total_duration)
		# Exit condition
		if current_time == total_duration:
			parent_machine.set_state("attached")


class AttachedState extends PlayerState:
	var max_duration: float = 2.75
	var rotation_speed: float = 2.284794657
	var current_time: float = 0

	func get_name():
		return "attached"
	
	func enter():
		print("Attached")
		current_time=0

	func update(delta, parent_machine):
		current_time+=delta
		player.position = player.position.rotated(rotation_speed*delta)
		# Exit condition
		if current_time >= max_duration:
			parent_machine.set_state("detaching")
			
	func exit():
		player.reparent(player.scene_root)


class DetachingState extends PlayerState:
	var total_duration: float = 0.2
	var current_time: float = 0.0
	var start_position: Vector2 = Vector2(0,0)
	var target_position: Vector2 = Vector2(0,0)

	func get_name():
		return "detaching"

	func enter():
		print("Detaching")
		current_time=0
		start_position = player.position
		# TODO find a valid landing spot (for now just in place)
		target_position = player.position

	func update(delta, parent_machine):
		# Lerp into position
		current_time+=delta
		current_time=min(total_duration, current_time)
		player.position=lerp(start_position, target_position, current_time/total_duration)
		# Exit conditions
		if current_time == total_duration:
			parent_machine.set_state("normal")
	

# TODO input handling
# I want a short buffer so that certain inputs gets queued if I want
#
