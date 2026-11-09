class_name ParentSyncComponent
extends Node

var root_node: Node
var current_anchor_path: NodePath
@export var desired_anchor_path: NodePath
@onready var synchronizer: CustomSynchronizer = $"../CustomSynchronizer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	synchronizer.pre_write.connect(_on_synchronizer_pre_write)
	synchronizer.pre_read.connect(_on_synchronizer_pre_read)
	root_node = get_parent()
	current_anchor_path = root_node.get_parent().get_path()
	desired_anchor_path = current_anchor_path

func _on_synchronizer_pre_write():
	if not is_multiplayer_authority():
		print("DES: ", desired_anchor_path, " CUR: ", current_anchor_path)
		if desired_anchor_path != current_anchor_path:
			print("recv: ", desired_anchor_path)
			current_anchor_path = desired_anchor_path
			root_node.reparent(get_node(desired_anchor_path))

func _on_synchronizer_pre_read():
	if is_multiplayer_authority():
		desired_anchor_path = root_node.get_parent().get_path()
		print("P: ", desired_anchor_path)
		
