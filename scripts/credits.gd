extends Control

var is_walking: bool = false
var speed: float = 150.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var scroll_speed: float = 40.0

@onready var player = $CharacterBody2D
@onready var anim_player = $AnimationPlayer
@onready var stop_pos = $stop_pos
@onready var back_btn = $Control/CenterContainer/back

@onready var credits_label = $RichTextLabel

func _ready() -> void:
	anim_player.play("stop")

func _physics_process(delta: float) -> void:
	
	if not player.is_on_floor():
		player.velocity.y += gravity * delta
	
	if is_walking:
		player.velocity.x = speed
		if is_instance_valid(stop_pos):
			if player.global_position.x >= stop_pos.global_position.x:
				player.global_position.x = stop_pos.global_position.x
				player.velocity.x = 0
				is_walking = false
				
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		player.velocity.x = 0
		
	player.move_and_slide()

func _process(delta: float) -> void:
	if is_instance_valid(credits_label):
		credits_label.position.y -= scroll_speed * delta

func _on_back_pressed() -> void:
	if not is_walking:
		is_walking = true
		anim_player.play("start")
		back_btn.hide()
