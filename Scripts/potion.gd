extends Area2D
# Scene logic for an in-world potion object.
# Handles input, dragging, throwing, and UI interaction.
# All gameplay data comes from PotionData.

# -------------------------
# Interaction state
# -------------------------
var dragging := false
var throwing := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO

# Click vs drag detection
var click_start_pos := Vector2.ZERO
const CLICK_THRESHOLD := 8.0

# Tracks whether THIS potion received the click this frame
var clicked_this_frame := false


# -------------------------
# Scene references
# -------------------------
@onready var cursor: Sprite2D = $Cursor
@onready var impact_particles: GPUParticles2D = $ImpactParticles

# Original cursor scale (used for animation reset)
var cursor_base_scale := Vector2.ONE


# -------------------------
# Potion data
# -------------------------
# Reference to the data resource describing this potion.
# This lets the same potion scene represent many different potions.
@export var potion_data: PotionData


# Text used to describe effects in the UI.
# Keys MUST be strings to match ingredient effect keys.
var effectDescriptions := {
	"damage": "Damages target by ",
	"healing": "Heals target by "
}


func _ready():
	input_pickable = true
	original_position = global_position
	cursor.visible = false
	cursor_base_scale = cursor.scale

	# -------------------------
	# TEMP: Hard-coded test potion
	# Remove when crafting is implemented
	# -------------------------
	if potion_data == null:
		potion_data = PotionData.new()
		potion_data.display_name = "Debug Test Potion"
		potion_data.ingredients = [
			preload("res://Items/Ingredients/Mushroom.tres"),
			preload("res://Items/Ingredients/Frog_Leg.tres")
		]
		potion_data.rebuild_effects()

	# -------------------------
	# Normal rebuild
	# -------------------------
	if potion_data:
		potion_data.rebuild_effects()



# -------------------------
# Input handling
# -------------------------
func _input_event(viewport, event, shape_idx):
	if throwing:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start click / drag tracking
			clicked_this_frame = true
			click_start_pos = get_global_mouse_position()
			_start_drag()
		else:
			# Determine whether this was a click or a drag
			var release_pos = get_global_mouse_position()
			var moved_distance = click_start_pos.distance_to(release_pos)

			if moved_distance <= CLICK_THRESHOLD:
				_on_click()
			else:
				_end_drag()


func _process(_delta):
	# Follow mouse while dragging
	if dragging and not throwing:
		global_position = get_global_mouse_position() + drag_offset


# -------------------------
# UI text building
# -------------------------
func _build_potion_info_text() -> String:
	if potion_data == null:
		return ""

	var text := ""

	# Loop through each effect the potion has
	for effect in potion_data.effects.keys():
		if effectDescriptions.has(effect):
			text += effectDescriptions[effect] \
				+ str(potion_data.effects[effect]) + "\n"

	return text.strip_edges()


# -------------------------
# Drag & drop logic
# -------------------------
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
		_:
			global_position = original_position


func _get_hovered_target() -> Area2D:
	for area in get_overlapping_areas():
		if area.name in ["Player", "Enemy", "Background"]:
			return area
	return null


# -------------------------
# Click behavior
# -------------------------
func _on_click():
	dragging = false
	z_index = 0
	
	# Ignores an error if the potion is empty.
	if potion_data == null:
		return

	# Update selected potion UI
	if get_parent().get_parent().has_node("SelectedPotion"):
		$"../../SelectedPotion/PotionName".text = potion_data.display_name
		$"../../SelectedPotion/PotionInfo".text = _build_potion_info_text()

	# Show and animate cursor
	cursor.visible = true
	cursor.scale = cursor_base_scale

	var tween := create_tween()
	tween.tween_property(cursor, "scale", cursor_base_scale * 1.15, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(cursor, "scale", cursor_base_scale, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


# -------------------------
# Throw animation
# -------------------------
func _throw_to(target_pos: Vector2):
	throwing = true
	dragging = false

	var start_pos := global_position
	var mid_pos := (start_pos + target_pos) * 0.5 + Vector2(0, -80)

	var tween := create_tween()
	tween.set_parallel(true)

	# Arc motion
	tween.tween_property(self, "global_position", mid_pos, 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.15)\
		.set_delay(0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Spin
	tween.tween_property(self, "rotation", rotation + deg_to_rad(25), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		rotation = 0
		throwing = false
		if impact_particles:
			impact_particles.restart()
	)


# -------------------------
# Cursor hiding logic
# -------------------------
func _hide_cursor():
	cursor.visible = false
	cursor.scale = cursor_base_scale


func _unhandled_input(event):
	if not cursor.visible:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		# Hide cursor if another potion was clicked
		if not clicked_this_frame:
			_hide_cursor()

	# Reset click tracking for next frame
	clicked_this_frame = false
	
	
