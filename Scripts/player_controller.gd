extends CharacterBody2D
class_name PlayerController

var player_state_machine: StateMachine
var scene_root: Node
var active_anchor: AttachAnchor

var attach_distance: float = 100
var command_buffer: CommandBuffer = CommandBuffer.new()

const BUFFERABLE_ACTIONS := ["attack"]
const TRACKED_ACTIONS := ["attack", "dodge", "special", "ranged"]

@onready var attach_hitbox: Area2D = $Hitbox 
@onready var attach_ray: RayCast2D = $RayCast2D

# Engine hooks

func _ready() -> void:
	scene_root = get_tree().current_scene
	
	player_state_machine = StateMachine.new()
	var states: Array[State]
	for state_type in [
		NormalState,
		# AttachingState,
		AttachedState,
		ForcedMovement
		# DetachingState
	]:
		states.append(state_type.new(self, player_state_machine))
	player_state_machine.set_states(states)

func _physics_process(delta: float) -> void:
	player_state_machine.run_state_physics_update(delta)

func _process(delta: float) -> void:
	player_state_machine.run_state_update(delta)

func _input(event: InputEvent) -> void:
	for action in TRACKED_ACTIONS:
		if event.is_action_pressed(action):
			handle_command(CommandEvent.new(action, CommandEvent.Type.PRESSED, player_state_machine.current_tick))
		elif event.is_action_released(action):
			handle_command(CommandEvent.new(action, CommandEvent.Type.RELEASED, player_state_machine.current_tick))

func handle_command(command_event: CommandEvent) -> void:
	var handled := player_state_machine.run_state_command_update(command_event)
	if not handled and command_event.is_pressed():
		if command_event.action in BUFFERABLE_ACTIONS:
			command_buffer.buffer(command_event.action, command_event.tick)


# General functions #
func attach(other: AttachAnchor):
	if active_anchor:
		active_anchor.lose_attachment(self)
	active_anchor = other
	reparent(active_anchor)
	active_anchor.receive_attachment(self)

func detach():
	reparent(scene_root)
	active_anchor.lose_attachment(self)
	active_anchor = null
	
func perform_movement(movement_speed: float):
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * movement_speed
	move_and_slide()



# State definitions #
# TODO Maybe entity state might want the same things as PlayerState
# TODO Hence we might want to just move this to base State and make it more generic
class PlayerState extends State:
	var player: PlayerController
	func _init(player: PlayerController, parent_machine: StateMachine):
		super(parent_machine)
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

	func update(delta):
		pass

	func physics_update(delta: float):
		player.perform_movement(movement_speed)
	
	func command_update(command_event: CommandEvent) -> bool:
		if command_event.is_action("special") and command_event.is_pressed():
			if player.attach_ray.is_colliding():
				player.attach(player.attach_ray.get_collider())
				(parent_machine.states["forced-movement"] as ForcedMovement).configure(
					"attached",
					0.2,
					player.position.normalized()*player.attach_distance
				)
				parent_machine.set_state("forced-movement")
			return true
		return false



# TODO can we make states generic enough to have a forced movement state that can take parameters
class ForcedMovement extends PlayerState: # TODO se note on PlayerState
	var total_duration: float = 0.2
	var current_time: float = 0.0
	var start_position: Vector2 = Vector2(0,0)
	var target_position: Vector2 = Vector2(0,0)
	var exit_state: String = "normal"

	func configure(exit_state: String, duration: float, target_position: Vector2):
		self.exit_state = exit_state
		self.total_duration = duration
		self.target_position = target_position

	func get_name():
		return "forced-movement"

	func enter():
		print("Forced movement!")
		current_time=0
		start_position = player.position
		# target_position = player.position.normalized()*player.attach_distance

	func update(delta):
		# Lerp into position
		current_time+=delta
		current_time=min(total_duration, current_time)
		player.position=lerp(start_position, target_position, current_time/total_duration)
		# Exit condition
		if current_time == total_duration:
			parent_machine.set_state(exit_state)


class AttachedState extends PlayerState:
	var max_duration: float = 2.75
	var rotation_speed: float = 2.284794657
	var current_time: float = 0

	func transition():
		player.detach()
		(parent_machine.states["forced-movement"] as ForcedMovement).configure(
			"normal",
			0.2,
			player.position # TODO find a valid landing spot (for now just in place)
			# TODO this causes bug where I guess this position doesnt update until next frame after detach
		)
		parent_machine.set_state("forced-movement")

	func get_name():
		return "attached"
	
	func enter():
		print("Attached")
		if player.command_buffer.try_consume("attack", parent_machine.current_tick, 60):
			print("ATTACK USING BUFFERED INPUT!")
		current_time=0

	func update(delta):
		current_time+=delta
		player.position = player.position.rotated(rotation_speed*delta)
		# Exit condition
		if current_time >= max_duration:
			#parent_machine.set_state("detaching")
			transition()
	
	func command_update(command_event: CommandEvent):
		if command_event.is_action("special") and command_event.is_pressed():
			transition()
			return true
		if command_event.is_action("attack") and command_event.is_pressed():
			# TODO attack here
			print("ATTACK!")
			return true
		return false

	# func get_cancel_options() -> Dictionary: # TODO implement cancelling
	# 	return {"attack": "attached_kick", "special": "detach"} # TODO this doesnt work with forced movement



# class AttachingState extends PlayerState:
# 	var total_duration: float = 0.2
# 	var current_time: float = 0.0
# 	var start_position: Vector2 = Vector2(0,0)
# 	var target_position: Vector2 = Vector2(0,0)
# 
# 	func get_name():
# 		return "attaching"
# 
# 	func enter():
# 		print("AttaCHING")
# 		current_time=0
# 		start_position = player.position
# 		target_position = player.position.normalized()*player.attach_distance
# 	
# 	func update(delta):
# 		# Lerp into position
# 		current_time+=delta
# 		current_time=min(total_duration, current_time)
# 		player.position=lerp(start_position, target_position, current_time/total_duration)
# 		# Exit condition
# 		if current_time == total_duration:
# 			parent_machine.set_state("attached")

# class DetachingState extends PlayerState:
# 	var total_duration: float = 0.2
# 	var current_time: float = 0.0
# 	var start_position: Vector2 = Vector2(0,0)
# 	var target_position: Vector2 = Vector2(0,0)
# 
# 	func get_name():
# 		return "detaching"
# 
# 	func enter():
# 		print("Detaching")
# 		current_time=0
# 		start_position = player.position
# 		# TODO find a valid landing spot (for now just in place)
# 		target_position = player.position
# 
# 	func update(delta):
# 		# Lerp into position
# 		current_time+=delta
# 		current_time=min(total_duration, current_time)
# 		player.position=lerp(start_position, target_position, current_time/total_duration)
# 		# Exit conditions
# 		if current_time == total_duration:
# 			parent_machine.set_state("normal")
	
# class JumpingState extends PlayerState: # TODO is jumping just a substate inside Normal?
# 	# TODO Maybe make timed state component
#	var total_duration: float = 0.5
#	var current_time: float = 0.0
#
#	func get_name():
#		return "jumping"
#
#	func enter():
#		print("Jumping")


# TODO input handling
# I want a short buffer so that certain inputs gets queued if I want
#
