extends Area2D

@export var is_template := true
@export var stats : Dictionary = {
	health = 20,
	attack = 10
}

@export var enemy_data: EnemyData

@onready var cursor = $Cursor
@onready var cursor_base_scale = $Cursor.scale

var clicked_this_frame := false

# Effect descriptions (string keys!)
var effect_descriptions := {
	"health": "Max Health: ",
	"damage": "Deals Damage: "
}

var original_position: Vector2

signal attack(enemy)

func _ready():
	get_parent().end_turn.connect(_on_end_turn_button_down)
	if enemy_data == null:
		enemy_data = preload("res://Entities/Enemies/Wolf.tres")
	
func _input_event(_viewport, event, _shape_idx):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked_this_frame = true
		else:
			_on_click()
	
func _on_click():
	z_index = 0

	if enemy_data == null:
		return
		
	if get_tree().root.get_node("Global/Stage/Hand").has_node("SelectedTarget"):
		get_tree().root.get_node("Global/Stage/Hand/SelectedTarget/TargetName").text = enemy_data.display_name
		get_tree().root.get_node("Global/Stage/Hand/SelectedTarget/TargetInfo").text = _build_enemy_info_text()

	cursor.visible = true
	cursor.scale = cursor_base_scale

	var tween := create_tween()
	tween.tween_property(cursor, "scale", cursor_base_scale * 1.15, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(cursor, "scale", cursor_base_scale, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		
		
func _unhandled_input(event):
	if not cursor.visible:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		if not clicked_this_frame:
			_hide_cursor()

	clicked_this_frame = false
	
func _hide_cursor():
	cursor.visible = false
	cursor.scale = cursor_base_scale


func _on_end_turn_button_down():
	_play_attack_lunge()
	emit_signal("attack", self)


func _play_attack_lunge():
	# How far the enemy lunges
	var lunge_offset := Vector2(-30, 0)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Lunge forward
	tween.tween_property(
		self,
		"position",
		original_position + lunge_offset,
		0.12
	)

	# Return to original position
	tween.tween_property(
		self,
		"position",
		original_position,
		0.16
	).set_ease(Tween.EASE_IN)
	
func _build_enemy_info_text() -> String:
	if enemy_data == null:
		return ""

	var text := ""
	for effect in enemy_data.enemy_info.keys():
		if effect_descriptions.has(effect):
			text += effect_descriptions[effect] \
				+ str(enemy_data.enemy_info[effect]) + "\n"

	return text.strip_edges()
