extends CharacterBody2D

enum State {MOVE, ATTACK, TAKE_DAMAGE, DEAD}
var current_state: State = State.MOVE

var speed: float = 60.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var health: int = 5
var damage_to_player: int = 1

var target_to_x: float
var target_fro_x: float
var is_heading_to_fro: bool = true

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
		State.ATTACK, State.TAKE_DAMAGE, State.DEAD:
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

func change_state(new_state: State) -> void:
	if current_state == State.DEAD:
		return
		
	current_state = new_state
	
	match current_state:
		State.MOVE:
			anim_player.play("move")
		State.ATTACK:
			if player_target:
				var dir_to_player = sign(player_target.global_position.x - global_position.x)
				if dir_to_player != 0:
					sprite.flip_h = dir_to_player > 0
			
			anim_player.play("attack")
			perform_delayed_attack()
		State.TAKE_DAMAGE:
			anim_player.play("take_damage")
		State.DEAD:
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
		player_target = body
		await get_tree().create_timer(0.2).timeout
		if current_state == State.MOVE:
			change_state(State.ATTACK)

func _on_hit_box_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target = null
		
		if current_state == State.ATTACK:
			change_state(State.MOVE)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"die":
			queue_free()
			
		"take_damage":
			if current_state == State.DEAD: return 
			
			if player_target:
				change_state(State.ATTACK)
			else:
				change_state(State.MOVE)
				
		"attack":
			if current_state == State.DEAD or current_state == State.TAKE_DAMAGE: return
			
			if player_target:
				change_state(State.ATTACK)
			else:
				change_state(State.MOVE)


func perform_delayed_attack() -> void:
	await get_tree().create_timer(0.55).timeout
	
	if current_state == State.ATTACK and player_target != null:
		if player_target.has_method("take_damage"):
			player_target.take_damage(damage_to_player)
