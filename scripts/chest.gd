extends StaticBody2D

var is_open: bool = false

@onready var anim_player = $AnimationPlayer

func open_chest() -> void:
	if not is_open:
		is_open = true
		anim_player.play("open")
