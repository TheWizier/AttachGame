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
		AttachedState.new(self)
	]
	player_state_machine = StateMachine.new(states)

func _physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	# TODO move to state
	if Input.is_key_pressed(Key.KEY_A):
		translate(Vector2.LEFT*delta*30)
	if Input.is_key_pressed(Key.KEY_D):
		translate(Vector2.RIGHT*delta*30)
	if Input.is_action_just_pressed("attack"):
		if attach_ray.is_colliding():
			active_anchor = attach_ray.get_collider()
			player_state_machine.set_state("attaching")
	
		
	player_state_machine.run_state_update(delta)

# State definitions #

class PlayerState extends State:
	var player: PlayerController
	func _init(player: PlayerController):
		self.player = player

class NormalState extends PlayerState:
	#var states: Array[State] = [
		## States that run independently of the parent state machine
	#]
	func get_name():
		return "normal"
	#var arms_state_machine = StateMachine.new(states)
	func enter():
		print("Normal")
		pass
	func exit():
		pass
	func update(delta, parent):
		pass

class AttachingState extends PlayerState:
	var total_duration: float = 0.5
	var current_time: float = 0.0
	var start_position: Vector2 = Vector2(0,0)
	var target_position: Vector2 = Vector2(0,0)
	func get_name():
		return "attaching"

	func enter():
		print("AttaCHING")
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
	func get_name():
		return "attached"
	
	func enter():
		print("Attached")

	func update(delta, parent_machine):
		player.position.#TODO

	func exit():
		player.reparent(player.scene_root)

# TODO input handling
# I want a short buffer so that certain inputs gets queued if I want
#
