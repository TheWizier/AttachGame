class_name AttachCharacter
extends CharacterBody2D

# Group that every AttachAnchor must be in so remote peers can find it by id.
const ANCHOR_GROUP := &"position_anchors"

const WORLD_ID := 0

@export var relative_position: Vector2
@export var attached_to_id: int # For multiplayer sync

var _anchor: Node2D # NOTE Do not use _anchor directly, use attached_to instead!
var attached_to: Node2D:
	get:
		return _anchor
	set(node):
		_anchor = node
		attached_to_id = _id_of(node)

var _scene_root: Node2D

func _ready() -> void:
	_scene_root = get_tree().current_scene
	attached_to = _scene_root
	relative_position = global_position
 
func _process(_delta: float) -> void:
	if attached_to == null:
		return
		
	# If the anchor was freed under us: stay where we are, in world space.
	if not is_instance_valid(attached_to):
		attached_to = _scene_root
		relative_position = global_position - _scene_root.global_position
	
	# If attached_to_id was changed by network, then update the attached_to node.
	if _id_of(attached_to) != attached_to_id:
		attached_to = _find_anchor(attached_to_id)
		if attached_to == null:
			push_error("No anchor matches attach id: ", attached_to_id)
			return
	
	# Update actual position of node based on relative position and anchor
	global_position = attached_to.global_position + relative_position


 
func _find_anchor(id: int) -> Node2D:
	if id == WORLD_ID:
		return _scene_root
	for node in get_tree().get_nodes_in_group(ANCHOR_GROUP):
		var anchor := node as PositionAnchor
		if anchor != null and anchor.net_id == id:
			return anchor
	return null
 
func _id_of(node: Node2D) -> int:
	if node == null or node == _scene_root:
		return WORLD_ID
	var anchor := node as PositionAnchor
	if anchor == null or anchor.net_id == WORLD_ID:
		push_error(
			"AttachCharacter: '%s' must be an AttachAnchor with a non-zero net_id to be synced"
			% node.name
		)
		return WORLD_ID
	return anchor.net_id
