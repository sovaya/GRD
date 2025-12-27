extends Node2D

@export var stats : Dictionary = {
	energy = 3,
	obtained_ingredients = []
}

@onready var wholescene := self
@onready var next_scene_packed := preload("res://Scenes/potion_making.tscn")

var enemycount = 2

var dropslist: Array = []



func enemy_killed(drops):
	enemycount -= 1
	dropslist.append_array(drops)
	if enemycount <= 0:
		$Stage/BattleEnd.visible = true
		_spawn_drop_icons(dropslist)

func _spawn_drop_icons(drops: Array):
	var items_gained := $Stage/BattleEnd/ItemsGained

	# Clear old icons
	for child in items_gained.get_children():
		child.queue_free()

	var spacing := 48
	var total_width := (drops.size() - 1) * spacing

	for i in range(drops.size()):
		var drop: IngredientItemData = drops[i]

		if drop.icon == null:
			continue

		var sprite := Sprite2D.new()
		sprite.texture = drop.icon
		sprite.scale = Vector2(0.3, 0.3) # 50% size


		sprite.position = Vector2(
			(i * spacing) - (total_width / 2.0),
			0
		)

		items_gained.add_child(sprite)



func _on_continue_button_down():
	_slide_out_and_in()


func _slide_out_and_in():
	var viewport := get_viewport().get_visible_rect()
	var screen_width := viewport.size.x

	# --- Instantiate next scene ---
	var next_scene := next_scene_packed.instantiate()
	next_scene.position = Vector2(screen_width, 0) # start off-screen right
	get_tree().root.add_child(next_scene)

	# --- Tween both scenes ---
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Current scene slides left
	tween.tween_property(
		wholescene,
		"position",
		Vector2(-screen_width, 0),
		0.45
	)

	# Next scene slides to center (parallel)
	tween.parallel().tween_property(
		next_scene,
		"position",
		Vector2.ZERO,
		0.45
	)

	# Cleanup
	tween.finished.connect(func():
		queue_free()                 # remove old scene
		get_tree().current_scene = next_scene
	)
