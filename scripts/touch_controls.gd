extends CanvasLayer

@onready var left_btn = $left
@onready var right_btn = $right
@onready var jump_btn = $jump
@onready var tele_btn = $tele

@onready var player = get_parent()

var base_scales = {}

func _ready():
	
	var is_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	var has_touch = DisplayServer.is_touchscreen_available()
	
	if is_mobile or has_touch:
		show()
	else:
		hide()
		set_process_input(false) 

	var buttons = [left_btn, right_btn, jump_btn, tele_btn]
	for btn in buttons:
		base_scales[btn] = btn.scale
		btn.pressed.connect(_on_button_pressed.bind(btn))
		btn.released.connect(_on_button_released.bind(btn))

func _on_button_pressed(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", base_scales[btn] * 0.8, 0.05)

func _on_button_released(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", base_scales[btn], 0.1)

func _process(delta):
	if player and "sword_active" in player:
		if player.sword_active:
			tele_btn.modulate = Color(1.0, 0.0, 0.0, 1.0) 
		else:
			tele_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _input(event):
	if event is InputEventScreenTouch:
		var screen_width = get_viewport().get_visible_rect().size.x
		
		if event.position.x > screen_width / 2.0:
			if not _is_touching_button(event.position):
				if event.pressed:
					if player and not player.is_attacking:
						Input.action_press("attack")
				else:
					Input.action_release("attack")

func _is_touching_button(pos: Vector2) -> bool:
	var right_side_buttons = [jump_btn, tele_btn]
	
	for btn in right_side_buttons:
		if btn.is_pressed():
			return true
			
		if btn.shape and btn.shape is CircleShape2D:
			var local_pos = btn.to_local(pos)
			var center = Vector2.ZERO
			
			if btn.shape_centered and btn.texture_normal:
				center = btn.texture_normal.get_size() / 2.0
				
			if local_pos.distance_to(center) <= btn.shape.radius:
				return true
				
	return false
