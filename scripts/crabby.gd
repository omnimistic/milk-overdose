extends CharacterBody2D

var speed: float = 60.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var target_to_x: float
var target_fro_x: float
var is_heading_to_fro: bool = true

var damage_to_player = 9

var dead = false

@onready var sprite = $Sprite2d
@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	target_to_x = $to.global_position.x
	target_fro_x = $fro.global_position.x
	
	anim_player.play("moving")

func _physics_process(delta: float) -> void:
	
	$Area2D2/CollisionShape2D.disabled = dead
	
	if not is_on_floor():
		velocity.y += gravity * delta

	var target_x = target_fro_x if is_heading_to_fro else target_to_x
	
	if abs(global_position.x - target_x) < 2.0:
		is_heading_to_fro = !is_heading_to_fro
		target_x = target_fro_x if is_heading_to_fro else target_to_x
		
	var direction = sign(target_x - global_position.x)
	
	if not dead:
		velocity.x = direction * speed
	
	if direction != 0:
		sprite.flip_h = direction > 0
	
	if not dead:
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.is_air_slamming:
			$AnimationPlayer.play("die")
			dead = true
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		self.queue_free()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage_to_player)
