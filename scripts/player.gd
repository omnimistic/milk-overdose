extends CharacterBody2D

var speed = 150.0
const MAX_SPEED = 200.0
const ACCELERATION = 1000.0
const FRICTION = 1200.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.67
	
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION*delta)
	
	if direction > 0:
		$Sprite2D.flip_h = false
	elif direction < 0:
		$Sprite2D.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			$AnimationPlayer.play("idle")
		else:
			$AnimationPlayer.play("run")

	move_and_slide()
