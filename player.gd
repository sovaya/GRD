extends Area2D

@export var stats : Dictionary = {
	energy = 3,
	health = 20,
	attack = 5
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemy_container := get_tree().root.get_node("Global/Enemy")
	if enemy_container == null:
		push_error("Enemy node not found")
		return

	for enemy in enemy_container.get_children():
		if enemy.has_signal("attack"):
			enemy.attack.connect(_attacked)


func _attacked(enemy):
	stats.health -= enemy.stats.attack
	print("Attacked by ", enemy.stats.attack, ". Player health is now ",stats.health)
	$Health.text = "Health: %d" % stats.health


func _on_end_turn_button_down():
	stats.energy = 3
	$Energy.text = "Energy: %d" % stats.energy
