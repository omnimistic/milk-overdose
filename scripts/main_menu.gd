extends Control

var move = true
var is_transitioning = false

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	$AnimationPlayer.play("start")

func _physics_process(delta: float) -> void:
	var player_body = $CharacterBody2D
	
	if not player_body.is_on_floor():
		player_body.velocity.y += gravity * delta
	
	if move:
		player_body.velocity.x = 200.0
		
		if has_node("stop_pos") and not is_transitioning:
			var stop_node = $stop_pos
			if player_body.global_position.x >= stop_node.global_position.x:
				player_body.global_position.x = stop_node.global_position.x
				player_body.velocity.x = 0.0
				move = false 
				$AnimationPlayer.play("stop")
				stop_node.queue_free()
	else:
		player_body.velocity.x = 0.0
	
	if player_body.global_position.y > $fall_pos.global_position.y:
		var tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(transition_to_level)
		
	player_body.move_and_slide()

func _on_start_pressed() -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	move = true
	$AnimationPlayer.play("start")

func transition_to_level() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/l_1.tscn")

func _on_credits_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
