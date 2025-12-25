extends Area2D
# Represents the table where ingredients are laid out in a grid.

@export var ingredient_scene: PackedScene

# 4x4 grid positions (16 total)
var grid_positions: Array[Vector2] = []

# Ingredients pulled from inventory
var ingredients: Array[IngredientItemData] = []

# Ingredient nodes currently on the table
var ingredient_nodes: Array[Area2D] = []


func _ready():
	# Build grid positions once
	_build_grid_positions()

	# Pull ingredient data from the global inventory
	ingredients = PlayerInventory.get_ingredients()

	_spawn_ingredients()


# Create a 4x4 grid with spacing
func _build_grid_positions():
	var spacing := 160
	var start := Vector2(400,500)

	for y in range(4):
		for x in range(4):
			grid_positions.append(start + Vector2(x, y) * spacing)


func _spawn_ingredients():
	if ingredient_scene == null:
		push_error("ingredient_scene not assigned on Table")
		return

	ingredient_nodes.clear()

	var count: int = min(ingredients.size(), grid_positions.size())

	for i in range(count):
		var ingredient_data := ingredients[i]
		if ingredient_data == null:
			continue

		# Instantiate ingredient scene
		var ingredient_node: Area2D = ingredient_scene.instantiate()

		# Assign data + ownership
		ingredient_node.ingredient_data = ingredient_data
		ingredient_node.home_table = self
		ingredient_node.in_cauldron = false

		# Add to scene
		add_child(ingredient_node)

		# Place into correct grid slot
		ingredient_node.position = grid_positions[i]
		ingredient_node.original_position = ingredient_node.global_position

		# Track node
		ingredient_nodes.append(ingredient_node)


func return_ingredient(item_node: Area2D) -> void:
	# SAFETY: remove from old parent first
	if item_node.get_parent() != self:
		item_node.get_parent().remove_child(item_node)
		add_child(item_node)

	# Track node
	if not ingredient_nodes.has(item_node):
		ingredient_nodes.append(item_node)

	# Reset state
	item_node.in_cauldron = false
	item_node.home_cauldron = null
	item_node.dragging = false
	item_node.input_pickable = true
	item_node.z_index = 0

	# ✅ Add back to inventory
	if item_node.ingredient_data:
		PlayerInventory.add_item(item_node.ingredient_data)

	# Rebuild grid so everything lines up
	_rebuild_grid()

func _rebuild_grid():
	for i in range(ingredient_nodes.size()):
		var node := ingredient_nodes[i]
		node.position = grid_positions[i]
		node.original_position = node.global_position
