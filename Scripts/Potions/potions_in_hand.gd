extends Node2D

@export var amount := 3
@export var spacing := 100
@export var tween_time := 0.4

@onready var potion_template: Node2D = $"../Potion"
@onready var player: Node2D = get_tree().root.get_node("Global/Player")

func _ready():
	_spawn_potions()

func _spawn_potions():
	# Safety
	if potion_template == null or player == null:
		return

	# Total width of the group
	var total_width := (amount - 1) * spacing

	for i in range(amount):
		var potion: Node2D = potion_template.duplicate()
		potion.visible = true

		# Final (target) position
		var x_offset := (i * spacing) - (total_width / 2.0)
		var target_position := Vector2(x_offset, 0)

		# Start at player position (convert global → local)
		print(player.global_position)
		potion.position = player.position
		add_child(potion)

		# Tween to target position
		var tween := create_tween()
		tween.tween_property(
			potion,
			"position",
			target_position,
			tween_time
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_end_turn_button_down():
	_spawn_potions()
