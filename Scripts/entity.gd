extends Area2D

@export var is_template := true
@export var stats : Dictionary = {
	health = 20,
	attack = 10
}

var original_position: Vector2

signal attack(enemy)

func _ready():
	pass


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
