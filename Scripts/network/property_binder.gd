class_name PropertyBinder
extends Node

enum SyncMode { ALL, ALWAYS, ON_CHANGE }

@export var root_path: NodePath = ^".."
@export var synced_properties: Array[SyncedProperty] = []

signal pre_read
signal post_write

class PropertyEntry:
	var target: Object
	var property: NodePath
	var mode: SyncedProperty.Mode
	var last_value: Variant = null  # last value reported by read_changed()


var _entries: Array[PropertyEntry] = []


func _ready() -> void:
	var root := get_node_or_null(root_path)
	if root == null:
		push_error("PropertyBinder: root_path '%s' does not resolve" % root_path)
		return
	for synced_property in synced_properties:
		if synced_property == null:
			push_error("NULL PROPERTY!")
			continue
		var target: Object = root if synced_property.node_path.is_empty() else root.get_node_or_null(synced_property.node_path)
		if target == null:
			push_error("PropertyBinder: no node at '%s'" % synced_property.node_path)
			continue
		add_property(target, synced_property.property, synced_property.mode)
	print("PROPERIES: ", _entries)


## Register a property from code. Order matters: both peers must add the same synced_properties in the same order.
func add_property(target: Object, property: String, mode: SyncedProperty.Mode = SyncedProperty.Mode.ALWAYS) -> Error:
	if not is_instance_valid(target):
		return ERR_INVALID_PARAMETER
	var head := property.split(":")[0]
	if not _has_property(target, head):
		push_error("PropertyBinder: %s has no property '%s'" % [target, head])
		return ERR_DOES_NOT_EXIST
	var entry := PropertyEntry.new()
	entry.target = target
	entry.property = NodePath(property)
	entry.mode = mode
	_entries.append(entry)
	return OK


func get_count() -> int: # TODO: dead code?
	return _entries.size()


## Values of the selected synced_properties, in registration order.
func read_values(sync_mode: SyncMode = SyncMode.ALL) -> Array:
	pre_read.emit()
	return (
		_entries
		.filter(filter_by_sync_mode.bind(sync_mode))
		.map(_read_property)
	)


## Apply values produced by read_values() with the same filter. Call on receivers only.
func write_values(values: Array, sync_mode: SyncMode = SyncMode.ALL) -> Error:
	# print("RECVDATA: ", values)
	var selected: Array[PropertyEntry] = (
		_entries
		.filter(filter_by_sync_mode.bind(sync_mode))
	)
	if values.size() != selected.size():
		push_error("PropertyBinder: got %d values for %d synced_properties" % [values.size(), selected.size()])
		return ERR_INVALID_PARAMETER
	for i in selected.size():
		_write_property(selected[i], values[i])
	post_write.emit()
	return OK


## ON_CHANGE synced_properties whose value differs from the last call. Returns {index: value},
## where index is the position in registration order. The first call reports all of them.
func read_changed() -> Dictionary:
	var out := {}
	for i in _entries.size():
		var entry := _entries[i]
		if entry.mode != SyncedProperty.Mode.ON_CHANGE:
			continue
		var value: Variant = _read_property(entry)
		if typeof(value) != typeof(entry.last_value) or value != entry.last_value:
			entry.last_value = value
			out[i] = value
	return out


func write_changed(changes: Dictionary) -> void:
	for i: int in changes:
		if i >= 0 and i < _entries.size():
			_write_property(_entries[i], changes[i])


func _read_property(entry: PropertyEntry) -> Variant:
	if not is_instance_valid(entry.target):
		push_error("Missing read property target: ", entry.target)
		return null
	return entry.target.get_indexed(entry.property)


func _write_property(entry: PropertyEntry, value: Variant) -> void:
	if is_instance_valid(entry.target):
		entry.target.set_indexed(entry.property, value)
	else:
		push_error("Missing read property target: ", entry.target)


static func _has_property(target: Object, name: String) -> bool:
	for property in target.get_property_list():
		if property.name == name:
			return true
	return false

func filter_by_sync_mode(entry: PropertyEntry, sync_mode: SyncMode) -> bool: # TODO: I dont use this yet
	match sync_mode:
		SyncMode.ALWAYS:
			return entry.mode == SyncedProperty.Mode.ALWAYS
		SyncMode.ON_CHANGE:
			return entry.mode == SyncedProperty.Mode.ON_CHANGE
	return true

# TODO: Need custom spawner to remove ists deletion attempts
