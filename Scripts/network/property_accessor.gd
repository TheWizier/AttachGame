class_name PropertyAccessor
extends MultiplayerSynchronizer
## Reuses MultiplayerSynchronizer for its editor panel and config only.
## The engine's own replication is neutralised at runtime; this node sends nothing.
## Do NOT add @tool: the swap below must never run in the editor, or it would save the empty config.

enum Filter { ALL, ALWAYS, ON_CHANGE, SPAWN }

var _config: SceneReplicationConfig  # the config you authored in the Replication panel
signal pre_read
signal pre_write
# NOTE: Dont use the built in signals as we broke them a bit :D

func _enter_tree() -> void:
	if _config == null:
		_config = replication_config
	# The engine reads replication_config lazily, so give it an empty one.
	replication_config = SceneReplicationConfig.new()


## Property paths in authored order, optionally filtered.
func get_paths(filter: Filter = Filter.ALL) -> Array[NodePath]:
	var out: Array[NodePath] = []
	if _config == null:
		return out
	for path: NodePath in _config.get_properties():
		if _matches(path, filter):
			out.append(path)
	return out


## Current values of the selected properties, in the same order as get_paths().
func read_values(filter: Filter = Filter.ALL) -> Array:
	pre_read.emit()
	var out: Array = []
	var root := get_node_or_null(root_path)
	if root == null:
		push_error("PropertyAccessor: root_path '%s' does not resolve" % root_path)
		return out
	for path in get_paths(filter):
		var target := _target(root, path)
		if target == null:
			push_error("PropertyAccessor: no node for '%s'" % path)
			out.append(null)
			continue
		out.append(target.get_indexed(_property(path)))
	return out


## Applies values (same order and filter as read_values) to the target properties.
func write_values(values: Array, filter: Filter = Filter.ALL) -> Error:
	pre_write.emit()
	var root := get_node_or_null(root_path)
	if root == null:
		push_error("PropertyAccessor: root_path '%s' does not resolve" % root_path)
		return ERR_UNCONFIGURED
	var paths := get_paths(filter)
	if values.size() != paths.size():
		push_error("PropertyAccessor: got %d values for %d properties" % [values.size(), paths.size()])
		return ERR_INVALID_PARAMETER
	var result := OK
	for i in paths.size():
		var target := _target(root, paths[i])
		if target == null:
			push_error("PropertyAccessor: no node for '%s'" % paths[i])
			result = ERR_DOES_NOT_EXIST
			continue
		target.set_indexed(_property(paths[i]), values[i])
	return result


func _matches(path: NodePath, filter: Filter) -> bool:
	match filter:
		Filter.ALWAYS:
			return _config.property_get_replication_mode(path) == SceneReplicationConfig.REPLICATION_MODE_ALWAYS
		Filter.ON_CHANGE:
			return _config.property_get_replication_mode(path) == SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE
		Filter.SPAWN:
			return _config.property_get_spawn(path)
	return true


# "Body:position:x" -> node "Body", property "position:x"; ".:position" -> the root itself
static func _target(root: Node, path: NodePath) -> Object:
	if path.get_name_count() == 0:
		return root
	return root.get_node_or_null(NodePath(path.get_concatenated_names()))


static func _property(path: NodePath) -> NodePath:
	return NodePath(path.get_concatenated_subnames())
