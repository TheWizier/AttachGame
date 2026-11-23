class_name ParentSyncComponent
extends Node

var root_node: Node2D
var current_anchor_path: NodePath
@export var desired_anchor_path: NodePath
@onready var synchronizer: CustomSynchronizer = $"../CustomSynchronizer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	synchronizer.post_write.connect(_on_synchronizer_post_write)
	synchronizer.pre_read.connect(_on_synchronizer_pre_read)
	synchronizer.add_property(self, "desired_anchor_path")
	root_node = get_parent()
	current_anchor_path = root_node.get_parent().get_path()
	desired_anchor_path = current_anchor_path

func _on_synchronizer_post_write():
	if not is_multiplayer_authority():
		# print("PUPPET DES: ", desired_anchor_path, " CUR: ", current_anchor_path)
		if desired_anchor_path != current_anchor_path:
			# print("PUPPET REPARENT!: ", desired_anchor_path)
			current_anchor_path = desired_anchor_path
			# Reparent, but don't translate the position
			var raw_position = root_node.position
			root_node.reparent(get_node(desired_anchor_path))
			root_node.position = raw_position

func _on_synchronizer_pre_read():
	if is_multiplayer_authority():
		desired_anchor_path = root_node.get_parent().get_path()
