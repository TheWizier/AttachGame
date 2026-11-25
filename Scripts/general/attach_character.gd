class_name AttachCharacter
extends CharacterBody2D

# Group that every AttachAnchor must be in so remote peers can find it by id.
const ANCHOR_GROUP := &"position_anchors"
const WORLD_ID := 0

@export var relative_position: Vector2
@export var attached_to_id: int # For multiplayer sync

var active_anchor: AttachAnchor
var scene_root: Node2D

var _anchor: Node2D # NOTE Do not use _anchor directly, use attached_to instead!
var attached_to: Node2D:
	get:
		return _anchor
	set(node):
		_anchor = node
		attached_to_id = _id_of(node)

func _ready() -> void:
	scene_root = get_tree().current_scene
	attached_to = scene_root
	relative_position = global_position
 
func _process(_delta: float) -> void:
		
	# If the anchor was freed under us: stay where we are, in world space.
	if not is_instance_valid(attached_to):
		attached_to = scene_root
		relative_position = global_position - scene_root.global_position
	
	# If attached_to_id was changed by network, then update the attached_to node.
	if _id_of(attached_to) != attached_to_id:
		_anchor = _find_anchor(attached_to_id)
		if attached_to == null:
			push_error("No anchor matches attach id: ", attached_to_id)
			return
	
	# Update actual position of node based on relative position and anchor
	global_position = attached_to.global_position + relative_position


func attach(other: AttachAnchor):
	# Stop attach if loop
	# TODO: we actually need to check if its a loop!!!
	# TODO: replace with proper loop check function
	# TODO: OR make it impossible to end up in that situation aka dont let raycast hit?
	var other_parent = other.get_parent() as AttachCharacter
	if other_parent != null and other_parent.attached_to_id == attached_to_id:
		print("ATTACH SAFEGUARD TRIGGERED!!!")
		return
	
	if active_anchor:
		active_anchor.lose_attachment(self)
	active_anchor = other
	print("RELPOS: ", relative_position)
	relative_position = attached_to.global_position+relative_position-other.global_position
	print("newRELPOS: ", relative_position)
	attached_to = active_anchor
	active_anchor.receive_attachment(self)

func detach():
	# reparent(scene_root)
	relative_position = attached_to.global_position+relative_position #No minus since scene root
	attached_to = scene_root
	active_anchor.lose_attachment(self)
	active_anchor = null
 
func _find_anchor(id: int) -> Node2D:
	if id == WORLD_ID:
		return scene_root
	for node in get_tree().get_nodes_in_group(ANCHOR_GROUP):
		var anchor := node as PositionAnchor
		if anchor != null and anchor.net_id == id:
			return anchor
	return null
 
func _id_of(node: Node2D) -> int:
	if node == null or node == scene_root:
		return WORLD_ID
	var anchor := node as PositionAnchor
	if anchor == null or anchor.net_id == WORLD_ID:
		push_error(
			"AttachCharacter: '%s' must be an AttachAnchor with a non-zero net_id to be synced"
			% node.name
		)
		print(node.net_id)
		return WORLD_ID
	return anchor.net_id
