extends Control

var has_reached_stop_point = false

func _ready() -> void:
	$AnimationPlayer.play("start")

func _process(delta: float) -> void:
	if not has_reached_stop_point:
		$Sprite2D.position.x += 200.0 * delta
		
		if $Sprite2D.position.x >= $stop_pos.position.x:
			$Sprite2D.position.x = $stop_pos.position.x
			has_reached_stop_point = true
			$AnimationPlayer.play("stop")


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/l_1.tscn")


func _on_credits_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
