extends Node2D

@export var key_scene: PackedScene

func _on_child_exiting_tree(node: Node) -> void:
	if get_child_count() == 1:
		var drop_position = node.global_position
		spawn_key.call_deferred(drop_position)

func spawn_key(drop_position: Vector2) -> void:
	if key_scene:
		var key = key_scene.instantiate()
		key.global_position = drop_position
		get_parent().add_child(key)
