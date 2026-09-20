extends Area2D

enum State {FOLLOW, TO_CHEST}
var current_state: State = State.FOLLOW

var player: Node2D
var chest_target: Node2D
var time_passed: float = 0.0

@onready var sprite = $Sprite2D

func _ready() -> void:
	
	var players = get_tree().get_nodes_in_group("player")
	player = players[0]

func _process(delta: float) -> void:
	match current_state:
		State.FOLLOW:
			if player:
				time_passed += delta
				
				var hover_offset = Vector2(0, -40)
				hover_offset.y += sin(time_passed * 6.0) * 8.0 
				
				var target_pos = player.global_position + hover_offset
				global_position = global_position.lerp(target_pos, 8.0 * delta)
				
		State.TO_CHEST:
			if chest_target:
				global_position = global_position.move_toward(chest_target.global_position, 200.0 * delta)
				
				if global_position.distance_to(chest_target.global_position) < 5.0:
					set_process(false) 
					chest_target.open_chest()
					play_insert_animation()

func _on_body_entered(body: Node2D) -> void:
	if current_state == State.FOLLOW and body.is_in_group("chest"):
		chest_target = body
		current_state = State.TO_CHEST

func play_insert_animation() -> void:
	var tween = create_tween()
	
	tween.tween_property(sprite, "scale", Vector2(1.8, 0.4), 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(0.2, 1.8), 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
