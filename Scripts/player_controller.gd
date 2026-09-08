extends CharacterBody2D
class_name PlayerController

var player_state_machine: StateMachine
var scene_root: Node
var active_anchor: Node

@onready var attach_hitbox: Area2D = $Hitbox 

func _ready() -> void:
	self.scene_root = get_tree().current_scene
	var states: Array[State] = [
		NormalState.new(self),
		AttachingState.new(self),
		AttachedState.new(self)
	]
	player_state_machine = StateMachine.new(states)

func _physics_process(delta: float) -> void:
	player_state_machine.run_state_update(delta)
	
func _process(delta: float) -> void:
	pass

# State definitions #

class NormalState extends State:
	#var states: Array[State] = [
		## States that run independently of the parent state machine
	#]
	func get_name():
		return "normal"
	#var arms_state_machine = StateMachine.new(states)
	func enter():
		pass
	func exit():
		pass
	func update(delta, parent):
		pass

class AttachingState extends State:
	var player_actor: PlayerController

	func _init(actor: PlayerController):
		super(actor)
		self.player_actor = actor

	func get_name():
		return "attaching"

	func enter():
		actor.reparent(self.player_actor.active_anchor)
	
	func update(delta, parent_machine):
		# Lerp to position
		# Then change state to attached
		pass

class AttachedState extends State:
	func get_name():
		return "attached"
	func update(delta, parent_machine):
		pass
		# TODO somehow get pos of attach node
		# lerp to position around it that rotates
		# (will break when things move so just lerp to starting position and then
		#  trasition to attached from perhaps attaching state. Maybe we need detatching state as well?
		# (or just rotate around by rotating the attach node and counter rotating us?
		# that means we get pushed back when the blade connects
	func exit():
		actor.reparent(self.root_node)

# TODO input handling
# I want a short buffer so that certain inputs gets queued if I want
#


func _on_attach_anchor_hit(anchor: Node2D) -> void:
	self.active_anchor = anchor
	player_state_machine.set_state("attaching")
