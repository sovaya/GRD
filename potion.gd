extends Area2D

var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO
var throwing := false

var click_start_pos := Vector2.ZERO
const CLICK_THRESHOLD := 8.0 # pixels

@onready var cursor: Sprite2D = $Cursor

var cursor_base_scale := Vector2.ONE

var clicked_this_frame := false



@onready var impact_particles: GPUParticles2D = $ImpactParticles

@export var potionName: String = "Potion of Damaging"
@export var potionInfo: Dictionary = {
	damage = Vector2i(1, 5),
	healing = Vector2i(1, 5)
}


func roll_potion_stats():
	randomize()

	for effect in potionInfo.keys():
		var range: Vector2i = potionInfo[effect]
		potionInfo[effect] = randi_range(range.x, range.y)


var effectDescriptions = {
	damage = "Damages Target by ",
	healing = "Heals Target by "
}

func _ready():
	input_pickable = true
	original_position = global_position
	cursor.visible = false
	cursor_base_scale = cursor.scale
	roll_potion_stats()



func _input_event(viewport, event, shape_idx):
	if throwing:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked_this_frame = true
			click_start_pos = get_global_mouse_position()
			_start_drag()
		else:
			var release_pos = get_global_mouse_position()
			var moved_distance = click_start_pos.distance_to(release_pos)

			if moved_distance <= CLICK_THRESHOLD:
				_on_click()
			else:
				_end_drag()


func _build_potion_info_text() -> String:
	var text := ""

	for effect in potionInfo.keys():
		if effectDescriptions.has(effect):
			text += effectDescriptions[effect] + str(potionInfo[effect]) + "\n"

	return text.strip_edges()


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


func _on_click():
	dragging = false
	z_index = 0

	# Equivalent of script.Parent.SelectedPotion.PotionName
	if get_parent().get_parent().has_node("SelectedPotion"):
		$"../../SelectedPotion/PotionName".text = potionName
		$"../../SelectedPotion/PotionInfo".text = _build_potion_info_text()
	cursor.visible = true
		
	cursor.scale = cursor_base_scale

	var tween := create_tween()

	tween.tween_property(
		cursor,
		"scale",
		cursor_base_scale * 1.15,
		0.08
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		cursor,
		"scale",
		cursor_base_scale,
		0.08
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


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
	
func _hide_cursor():
	cursor.visible = false
	cursor.scale = cursor_base_scale

func _unhandled_input(event):
	if not cursor.visible:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		# If this potion did NOT receive the click
		if not clicked_this_frame:
			_hide_cursor()

	# Reset for next click
	clicked_this_frame = false
