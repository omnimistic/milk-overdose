extends CharacterBody2D

enum State {MOVE, SPIN, TAKE_DAMAGE, DEAD}
var current_state: State = State.MOVE

var speed: float = 60.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var health: int = 2
var damage_to_player: int = 3
var knockback_strength: float = 300.0

var target_to_x: float
var target_fro_x: float
var is_heading_to_fro: bool = true
var is_anticipating: bool = false
var spin_direction: float = 0.0

var player_target: Node2D = null

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	target_to_x = $to.global_position.x
	target_fro_x = $fro.global_position.x
	change_state(State.MOVE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.MOVE:
			patrol_logic()
			check_for_player()
		State.SPIN:
			if is_anticipating:
				velocity.x = 0
			else:
				spin_logic()
		State.TAKE_DAMAGE, State.DEAD:
			velocity.x = 0 

	move_and_slide()

func patrol_logic() -> void:
	var target_x = target_fro_x if is_heading_to_fro else target_to_x

	if abs(global_position.x - target_x) < 2.0:
		is_heading_to_fro = !is_heading_to_fro
		target_x = target_fro_x if is_heading_to_fro else target_to_x

	var direction = sign(target_x - global_position.x)
	velocity.x = direction * speed

	if direction != 0:
		sprite.flip_h = direction > 0

func check_for_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		var min_x = min(target_to_x, target_fro_x)
		var max_x = max(target_to_x, target_fro_x)
		
		if p.global_position.x >= min_x and p.global_position.x <= max_x:
			var dir_to_p = sign(p.global_position.x - global_position.x)
			var facing = 1 if sprite.flip_h else -1
			
			if dir_to_p == facing:
				player_target = p
				change_state(State.SPIN)

func spin_logic() -> void:
	velocity.x = spin_direction * (speed * 1.6)
	
	if spin_direction != 0:
		sprite.flip_h = spin_direction > 0

func change_state(new_state: State) -> void:
	if current_state == State.DEAD:
		return
		
	current_state = new_state
	
	match current_state:
		State.MOVE:
			is_anticipating = false
			anim_player.play("move")
		State.SPIN:
			is_anticipating = true
			anim_player.play("spin")
			
			if player_target:
				spin_direction = sign(player_target.global_position.x - global_position.x)
				if spin_direction == 0:
					spin_direction = 1.0 if sprite.flip_h else -1.0
			else:
				spin_direction = 1.0 if sprite.flip_h else -1.0
				
			if spin_direction != 0:
				sprite.flip_h = spin_direction > 0
				
			await get_tree().create_timer(0.1).timeout
			if current_state == State.SPIN:
				is_anticipating = false
		State.TAKE_DAMAGE:
			is_anticipating = false
			anim_player.play("take_damage")
		State.DEAD:
			is_anticipating = false
			anim_player.play("die")
			if has_node("hit_box/CollisionShape2D"):
				$hit_box/CollisionShape2D.set_deferred("disabled", true)
			if has_node("hurt_box/CollisionShape2D"):
				$hurt_box/CollisionShape2D.set_deferred("disabled", true)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if current_state == State.DEAD:
		return
		
	if body.is_in_group("player") and body.is_attacking:
		receive_damage()

func receive_damage() -> void:
	if current_state == State.DEAD:
		return
		
	health -= 1
	
	if health <= 0:
		change_state(State.DEAD)
	else:
		change_state(State.TAKE_DAMAGE)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if current_state == State.DEAD:
		return
		
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var knockback_dir = sign(body.global_position.x - global_position.x)
			if knockback_dir == 0:
				knockback_dir = 1
			var knockback_vector = Vector2(knockback_dir * knockback_strength, -200.0)
			body.take_damage(damage_to_player, knockback_vector)
		elif body.has_method("die_from_fall"):
			body.die_from_fall()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"die":
			queue_free()
		"take_damage":
			if current_state == State.DEAD: return
			change_state(State.MOVE)
		"spin":
			if current_state == State.DEAD or current_state == State.TAKE_DAMAGE: return
			if player_target:
				var min_x = min(target_to_x, target_fro_x)
				var max_x = max(target_to_x, target_fro_x)
				if player_target.global_position.x >= min_x and player_target.global_position.x <= max_x:
					change_state(State.SPIN)
				else:
					player_target = null
					change_state(State.MOVE)
			else:
				change_state(State.MOVE)
