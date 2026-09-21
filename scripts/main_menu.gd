extends Control

var move = true
var is_transitioning = false
var has_triggered_fall = false
var next_scene_path = ""

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
	
	if player_body.global_position.y > $fall_pos.global_position.y and not has_triggered_fall:
		has_triggered_fall = true
		var tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(change_scene)
		
	player_body.move_and_slide()

func _on_start_pressed() -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	move = true
	next_scene_path = "res://scenes/levels/l_1.tscn"
	$AnimationPlayer.play("start")

func _on_credits_pressed() -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	move = true
	next_scene_path = "res://scenes/credits.tscn"
	$AnimationPlayer.play("start")


func change_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)

func _on_quit_pressed() -> void:
	get_tree().quit()
