extends Node2D

@export var amount := 3
@export var spacing := 100

@onready var potion_template: Node2D = $"../Potion"

func _ready():
	_spawn_potions()

func _spawn_potions():
	# Safety
	if potion_template == null:
		return

	# Total width of the group
	var total_width := (amount - 1) * spacing

	for i in range(amount):
		var potion = potion_template.duplicate()
		potion.visible = true

		# Centered offset
		var x_offset := (i * spacing) - (total_width / 2.0)
		potion.position = Vector2(x_offset, 0)

		add_child(potion)
