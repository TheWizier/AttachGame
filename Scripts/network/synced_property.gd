class_name SyncedProperty
extends Resource

enum Mode { ALWAYS, ON_CHANGE }

@export var node_path: NodePath = ^"."  # relative to the binder's root; "." means the root itself
@export var property: String = ""       # "position", or a sub-property like "position:x"
@export var mode: Mode = Mode.ALWAYS
