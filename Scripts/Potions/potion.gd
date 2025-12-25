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

var click_start_pos := Vector2.ZERO
const CLICK_THRESHOLD := 8.0
var clicked_this_frame := false

signal potion_cast(potion, target)


# -------------------------
# Scene references
# -------------------------
@onready var cursor: Sprite2D = $Cursor
@onready var impact_particles: GPUParticles2D = $ImpactParticles
var cursor_base_scale := Vector2.ONE


# -------------------------
# Potion data
# -------------------------
@export var potion_data: PotionData


# Effect descriptions (string keys!)
var effect_descriptions := {
	"energy": "Costs Energy: ",
	"damage": "Damages Target by ",
	"healing": "Heals Target by "
}


func _ready():
	input_pickable = true
	original_position = global_position
	cursor.visible = false
	cursor_base_scale = cursor.scale

	# -------------------------
	# TEMP: Debug potion if none assigned
	# Remove once crafting is implemented
	# -------------------------
	if potion_data == null:
		potion_data = PotionData.new()
		potion_data.display_name = "Debug Potion"
		potion_data.ingredients = [
			preload("res://Items/Ingredients/Frog_Leg.tres"),
		]
		potion_data.rebuild_effects()
		_roll_random_effects()

	else:
		potion_data.rebuild_effects()
		_roll_random_effects()


# -------------------------
# Randomization
# -------------------------
func _roll_random_effects():
	randomize()

	for effect in potion_data.effects.keys():
		var value = potion_data.effects[effect]
		if value is Vector2i:
			potion_data.effects[effect] = randi_range(value.x, value.y)


# -------------------------
# Input handling
# -------------------------
func _input_event(_viewport, event, _shape_idx):
	if throwing:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked_this_frame = true
			click_start_pos = get_global_mouse_position()
			_start_drag()
		else:
			var moved := click_start_pos.distance_to(get_global_mouse_position())
			if moved <= CLICK_THRESHOLD:
				_on_click()
			else:
				_end_drag()


func _process(_delta):
	if dragging and not throwing:
		global_position = get_global_mouse_position() + drag_offset


# -------------------------
# UI text
# -------------------------
func _build_potion_info_text() -> String:
	if potion_data == null:
		return ""

	var text := ""
	for effect in potion_data.effects.keys():
		if effect_descriptions.has(effect):
			text += effect_descriptions[effect] \
				+ str(potion_data.effects[effect]) + "\n"

	return text.strip_edges()


# -------------------------
# Drag & drop
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
	match target.get_parent().name:
		"Enemy":
			_throw_to(target)
		_:
			global_position = original_position


func _get_hovered_target() -> Area2D:
	for area in get_overlapping_areas():
		if area.get_parent().name in ["Player", "Enemy", "Background"]:
			return area
	return null


# -------------------------
# Click behavior
# -------------------------
func _on_click():
	dragging = false
	z_index = 0

	if potion_data == null:
		return

	if get_parent().get_parent().has_node("SelectedPotion"):
		$"../../SelectedPotion/PotionName".text = potion_data.display_name
		$"../../SelectedPotion/PotionInfo".text = _build_potion_info_text()

	cursor.visible = true
	cursor.scale = cursor_base_scale

	var tween := create_tween()
	tween.tween_property(cursor, "scale", cursor_base_scale * 1.15, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(cursor, "scale", cursor_base_scale, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


# -------------------------
# Throw & apply effects
# -------------------------
func _throw_to(target: Node):
	throwing = true
	dragging = false

	var target_pos: Vector2 = target.global_position
	var start_pos := global_position
	var mid_pos := (start_pos + target_pos) * 0.5 + Vector2(0, -80)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "global_position", mid_pos, 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.15)\
		.set_delay(0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_property(self, "rotation", rotation + deg_to_rad(25), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		rotation = 0
		throwing = false

		_apply_effects_to(target)

		if impact_particles:
			impact_particles.reparent(get_parent())
			impact_particles.finished.connect(impact_particles.queue_free)
			impact_particles.restart()

		queue_free()
	)


func _apply_effects_to(target: Node):
	if potion_data == null:
		return

	var effects := potion_data.effects

	
	emit_signal("potion_cast", self, target)

	if effects.has("damage") and target.stats:
		target.stats.health -= effects["damage"]
		target.get_node("Health").text = "Health: %d" % target.stats.health
		if target.stats.health <= 0:
			target.queue_free() # Kills the enemy, should put adding obtained ingredients logic in here
			get_tree().root.get_node("Global").enemy_killed() # This doesn't account for if there's multiple enemies yet
			

	if effects.has("healing") and target.stats:
		target.stats.health += effects["healing"]
		target.get_node("Health").text = "Health: %d" % target.stats.health

	# Energy cost intentionally NOT applied here
	# (usually handled by the player using the potion)


# -------------------------
# Cursor hiding
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
		if not clicked_this_frame:
			_hide_cursor()

	clicked_this_frame = false
