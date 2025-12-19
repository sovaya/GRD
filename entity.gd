extends Area2D

@export var is_template := true

func _ready():
	if not is_template:
		self.visible = true
		return

	var global = get_tree().root.get_node("Global")

	if global.has_node("Player"):
		var player_copy = duplicate()
		player_copy.is_template = false
		global.get_node("Player").add_child(player_copy)
		player_copy.name = "Player"

	if global.has_node("Enemy"):
		var enemy_copy = duplicate()
		enemy_copy.is_template = false
		global.get_node("Enemy").add_child(enemy_copy)
		enemy_copy.name = "Enemy"
