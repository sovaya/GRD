extends Area2D

@export var stats : Dictionary = {
	health = 20,
	attack = 5
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemy_container := get_tree().root.get_node("Global/Enemy")
	if enemy_container == null:
		push_error("Enemy node not found")
		return
		

	enemy_container.child_entered_tree.connect(func(enemy):
		if enemy.has_signal("attack"):
			enemy.attack.connect(_attacked)
	)
	var potion_container = get_tree().root.get_node("Global/Stage/Hand/PotionsInHand")

	# Connect when a potion gets used signal
	potion_container.child_entered_tree.connect(func(child):
		if child.has_signal("potion_cast"):
			child.potion_cast.connect(_on_potion_cast)
	)
	

func _attacked(enemy):
	stats.health -= enemy.stats.attack
	print("Attacked by ", enemy.stats.attack, ". Player health is now ",stats.health)
	$Health.text = "Health: %d" % stats.health

func _on_potion_cast(potion, target):
	get_tree().root.get_node("Global").stats.energy -= 1
	$Energy.text = "Energy: %d" % get_tree().root.get_node("Global").stats.energy


func _on_end_turn_button_down():
	get_tree().root.get_node("Global").stats.energy = 3
	$Energy.text = "Energy: %d" % get_tree().root.get_node("Global").stats.energy
