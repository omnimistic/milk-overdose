extends CharacterBody2D

var speed = 150.0
const MAX_SPEED = 200.0
const ACCELERATION = 1000.0
const FRICTION = 1200.0
const JUMP_VELOCITY = -400.0

var is_attacking:bool = false
var is_air_slamming:bool = false

var slam_extra_force = 4.0

var combo_active:bool = false
var combo_timer:float = 0.0
const COMBO_WINDOW:float = 0.8

var can_jump:bool = true
var has_jumped:bool = false

var cam_shake_strength:float = 0.0
var cam_shake_fade:float = 10.0

var is_tele_attacking:bool = false
var sword_active:bool = false
var sword_direction:float = 1.0
const SWORD_SPEED:float = 160.0
@onready var tele_sword = $tele_attack_sword
@onready var tele_sword_sprite_location = $tele_attack_sword/tele_cam_location
@onready var tele_sword_col = $tele_attack_sword/tele_sword_hitbox/CollisionShape2D


var sword_rest_pos:Vector2
var sword_rest_scale:Vector2
var sword_cam_rest_pos:Vector2
var sword_col_rest_pos:Vector2

var juice_scale_vel:Vector2 = Vector2.ZERO
var spring_k:float = 200.0
var damp_c:float = 15.0
var flash_timer:float = 0.0

@onready var tele_sword_cam_ui = $HUD/tele_sword_cam_mask
@onready var tele_sword_viewport = $HUD/tele_sword_cam_mask/SubViewportContainer/SubViewport
@onready var tele_sword_cam = $HUD/tele_sword_cam_mask/SubViewportContainer/SubViewport/tele_sword_cam

var is_tele_sword_crashing:bool = false

func _ready() -> void:
	if tele_sword:
		sword_rest_pos = tele_sword.position
		sword_rest_scale = tele_sword.scale
		tele_sword.visible = false
		tele_sword.top_level = false
		sword_cam_rest_pos = tele_sword_sprite_location.position
	
	if tele_sword_viewport:
		tele_sword_viewport.world_2d = get_viewport().world_2d
		tele_sword_cam_ui.visible = false
	
	if tele_sword_col:
		sword_col_rest_pos = tele_sword_col.position

func _process(delta: float) -> void:
	if cam_shake_strength > 0:
		cam_shake_strength = lerpf(cam_shake_strength, 0, cam_shake_fade * delta)
		$Camera2D.offset = Vector2(randf_range(-cam_shake_strength, cam_shake_strength), randf_range(-cam_shake_strength, cam_shake_strength))
	else:
		$Camera2D.offset = Vector2.ZERO
	
	var displacement = $Sprite2D.scale - Vector2(1.0, 1.0)
	juice_scale_vel -= (displacement * spring_k) * delta
	juice_scale_vel -= (juice_scale_vel * damp_c) * delta
	$Sprite2D.scale += juice_scale_vel * delta
	
	if flash_timer > 0:
		flash_timer -= delta
		$Sprite2D.modulate = Color(5.0, 5.0, 5.0, 1.0)
	else:
		$Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)


func apply_camera_shake(strength:float) -> void:
	cam_shake_strength = strength


func _physics_process(delta: float) -> void:
	
	if sword_active and tele_sword and not is_tele_sword_crashing:
		tele_sword.global_position.x += sword_direction * SWORD_SPEED * delta
		tele_sword_cam.global_position = tele_sword_sprite_location.global_position
	
	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_active = false
	
	# Add the gravity.
	if not is_on_floor():
		if is_air_slamming:
			velocity += (get_gravity() * slam_extra_force) * delta
		else:
			velocity += get_gravity() * delta
	else:
		if is_air_slamming and $AnimationPlayer.current_animation == "attack_4_fall":
			$AnimationPlayer.play("attack_4_end")
			apply_camera_shake(15.0)
		
	if is_on_floor():
		has_jumped = false
		can_jump = true
	
	if Input.is_action_just_pressed("ui_accept") and not is_attacking and not is_tele_attacking:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			has_jumped = true
		elif can_jump:
			velocity.y = JUMP_VELOCITY
			can_jump = false
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.67
	
	if Input.is_action_just_pressed("attack") and not is_tele_attacking:
		if not is_on_floor():
			if not is_air_slamming:
				is_air_slamming = true
				is_attacking = true
				velocity.x = 0
				velocity.y = 200.0
				$AnimationPlayer.play("attack_4_fall")
		else:
			if not is_attacking and not is_tele_attacking:
				is_attacking = true
				combo_timer = COMBO_WINDOW
				
				if not combo_active:
					combo_active = true
					$AnimationPlayer.play("attack_1")
				else:
					if randi() % 2 == 0:
						$AnimationPlayer.play("attack_2")
					else:
						$AnimationPlayer.play("attack_3")
						
	if Input.is_action_just_pressed("tele_attack"):
		if sword_active and not is_tele_sword_crashing:
			reset_tele_sword(true)
		else:
			if not is_attacking and not is_tele_attacking:
				is_tele_attacking = true
				velocity.x = 0
				$AnimationPlayer.play("tele_attack")

	
	var direction := 0.0
	if not is_attacking and not is_tele_attacking:
		direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION*delta)
	
	if direction > 0:
		$Sprite2D.flip_h = false
		if not sword_active:
			tele_sword.position.x = abs(tele_sword.position.x)
	elif direction < 0:
		$Sprite2D.flip_h = true
		if not sword_active:
			tele_sword.position.x = -abs(tele_sword.position.x)
	
	if not is_attacking and not is_tele_attacking:
		if is_on_floor():
			if direction == 0:
				$AnimationPlayer.play("idle")
			else:
				$AnimationPlayer.play("run")
		else:
			if velocity.y < -50.0:
				$AnimationPlayer.play("jump_up")
			elif velocity.y > 50.0:
				$AnimationPlayer.play("fall_down")
			else:
				pass
	
	$Sprite2D/dust.emitting = abs(velocity.x) > 10 and is_on_floor()
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_4_fall":
		return
	
	if anim_name.begins_with("attack"):
		is_attacking = false
		is_air_slamming = false
	
	if anim_name == "tele_attack":
		is_tele_attacking = false
		sword_active = true
		
		var saved_global_pos = tele_sword.global_position
		var saved_global_scale = tele_sword.global_scale
		
		tele_sword.top_level = true
		tele_sword.global_position = saved_global_pos
		tele_sword.global_scale = saved_global_scale
		tele_sword.visible = true
		
		if tele_sword_cam_ui:
			tele_sword_cam_ui.visible = true
		
		if $Sprite2D.flip_h:
			sword_direction = -1.0
			$tele_attack_sword/TeleAttackSword.flip_h = true
			tele_sword_sprite_location.position.x = -abs(sword_cam_rest_pos.x)
			tele_sword_col.position.x = -abs(sword_col_rest_pos.x)
		else :
			sword_direction = 1.0
			$tele_attack_sword/TeleAttackSword.flip_h = false
			tele_sword_sprite_location.position.x = abs(sword_cam_rest_pos.x)
			tele_sword_col.position.x = abs(sword_col_rest_pos.x)


func die_from_fall():
	$HUD/ColorRect.visible = true
	$HUD/ColorRect.modulate.a = 0.0
	
	var tween = create_tween()
	
	tween.tween_property($HUD/ColorRect, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.3)
	tween.tween_callback(get_tree().reload_current_scene)


func _on_tele_sword_hitbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		if not sword_active or is_tele_sword_crashing:
			return
		
		is_tele_sword_crashing = true
		apply_camera_shake(5.0)
		
		$tele_attack_sword/TeleAttackSword.modulate = Color(5.0, 5.0, 5.0, 1.0)
		var tween = create_tween()
		tween.tween_interval(0.2)
		tween.tween_callback(reset_tele_sword.bind(false))


func reset_tele_sword(teleport_player:bool) -> void:
	sword_active = false
	is_tele_sword_crashing = false
	
	if teleport_player:
		global_position = tele_sword_sprite_location.global_position
		velocity = Vector2.ZERO
		apply_camera_shake(20.0)
		$Sprite2D.scale = Vector2(0.2, 2.5)
		flash_timer = 0.15
	
	tele_sword.visible = false
	tele_sword.top_level = false
	tele_sword.position = sword_rest_pos
	tele_sword.scale = sword_rest_scale
	$tele_attack_sword/TeleAttackSword.modulate = Color(1.0, 1.0, 1.0, 1.0)

	tele_sword_cam_ui.visible = false
	
	if $Sprite2D.flip_h:
		tele_sword.position.x = -abs(tele_sword.position.x)
		tele_sword_sprite_location.position.x = -abs(sword_cam_rest_pos.x)
		tele_sword_col.position.x = -abs(sword_col_rest_pos.x)
	else:
		tele_sword.position.x = abs(tele_sword.position.x)
		tele_sword_sprite_location.position.x = abs(sword_cam_rest_pos.x)
		tele_sword_col.position.x = abs(sword_col_rest_pos.x)
