extends Area2D

var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO
var throwing := false

@onready var impact_particles: GPUParticles2D = $ImpactParticles


func _ready():
	input_pickable = true
	original_position = global_position


func _input_event(viewport, event, shape_idx):
	if throwing:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag()
			else:
				_end_drag()


func _start_drag():
	dragging = true
	drag_offset = global_position - get_global_mouse_position()
	original_position = global_position
	z_index = 100


func _end_drag():
	dragging = false
	z_index = 0

	var target := _get_hovered_target()
	if target == null:
		global_position = original_position
		return

	match target.name:
		"Player", "Enemy":
			_throw_to(target.global_position)
		"Background":
			global_position = original_position
		_:
			global_position = original_position


func _process(_delta):
	if dragging and not throwing:
		global_position = get_global_mouse_position() + drag_offset


func _get_hovered_target() -> Area2D:
	for area in get_overlapping_areas():
		if area.name in ["Player", "Enemy", "Background"]:
			return area
	return null
func _throw_to(target_pos: Vector2):
	throwing = true
	dragging = false

	var start_pos := global_position
	var mid_pos := (start_pos + target_pos) * 0.5 + Vector2(0, -80)

	var tween := create_tween()
	tween.set_parallel(true)

	# Arc motion
	tween.tween_property(self, "global_position", mid_pos, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "global_position", target_pos, 0.15)\
		.set_delay(0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	# Spin
	tween.tween_property(self, "rotation", rotation + deg_to_rad(25), 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		rotation = 0
		throwing = false

		if impact_particles:
			impact_particles.restart()
	)
