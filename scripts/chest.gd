extends StaticBody2D

var is_open: bool = false

@onready var anim_player = $AnimationPlayer

func open_chest() -> void:
	if not is_open:
		is_open = true
		anim_player.play("open")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open":
		var current_path = get_tree().current_scene.scene_file_path
		var file_name = current_path.get_file()
		var current_level = file_name.trim_prefix("l_").trim_suffix(".tscn").to_int()
		var next_level_path = "res://scenes/levels/l_%d.tscn" % (current_level + 1)
		if current_level < 2:
			get_tree().change_scene_to_file(next_level_path)
		elif current_level == 2:
			get_tree().change_scene_to_file("res://scenes/credits.tscn")
