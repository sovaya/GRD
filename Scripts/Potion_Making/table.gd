extends Area2D
# Represents the table where ingredients are laid out in a grid.

@export var ingredient_scene: PackedScene

# 4x4 grid positions (16 total)
var grid_positions: Array[Vector2] = []

# Ingredients pulled from inventory
var ingredients: Array[IngredientItemData] = []


func _ready():
	# Build grid positions once
	_build_grid_positions()

	# Pull ingredient data from the global inventory
	ingredients = PlayerInventory.get_ingredients()

	print("Table received ingredients:", ingredients)

	_spawn_ingredients()


# Create a 4x4 grid with spacing
func _build_grid_positions():
	var spacing := 64
	var start := Vector2(500,500)

	for y in range(4):
		for x in range(4):
			grid_positions.append(start + Vector2(x, y) * spacing)


func _spawn_ingredients():
	if ingredient_scene == null:
		push_error("ingredient_scene not assigned on Table")
		return

	var count: int = min(ingredients.size(), grid_positions.size())

	for i in range(count):
		var ingredient_data := ingredients[i]
		if ingredient_data == null:
			continue

		# Instantiate ingredient
		var ingredient_node := ingredient_scene.instantiate()

		# Assign data
		ingredient_node.ingredient_data = ingredient_data

		# Add to the table FIRST
		add_child(ingredient_node)

		# Then set LOCAL position relative to the table
		ingredient_node.position = grid_positions[i]
