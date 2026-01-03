extends Node2D

@export var amount := 2
@export var spacing := 130

@onready var enemy_template = preload("res://Scenes/entity.tscn")

var wolf = preload("res://Resources/Entities/Enemies/Wolf.tres")

signal end_turn()

func _ready():
	
	_spawn_enemies()

func _spawn_enemies():
	# Safety
	if enemy_template == null:
		return

	# Total width of the group
	var total_width := (amount - 1) * spacing

	for i in range(amount):
		var enemy = enemy_template.instantiate()
		enemy.get_node("Sprite").texture = wolf.icon
		enemy.get_node("Sprite").scale.x = 3
		enemy.get_node("Sprite").scale.y = 3
		enemy.visible = true

		# Centered offset
		var x_offset := (i * spacing) - (total_width / 2.0)
		enemy.position = Vector2(x_offset, 0)

		add_child(enemy)


func _on_enemy_turn():
	emit_signal("end_turn")
