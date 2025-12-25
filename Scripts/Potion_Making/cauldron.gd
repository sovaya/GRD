extends Area2D
# Represents the cauldron where ingredients are dropped and temporarily stored

# -------------------------
# Configuration
# -------------------------

# Center position of the cauldron grid (world position)
const GRID_CENTER := Vector2(600, 300)

# Grid layout
const GRID_COLUMNS := 4
const GRID_ROWS := 4
const GRID_SPACING := 100


# -------------------------
# State
# -------------------------

# Ingredient DATA currently in the cauldron (used for potion crafting)
var mix: Array[IngredientItemData] = []

# Visual nodes currently placed in the cauldron
var ingredient_nodes: Array[Area2D] = []

# Precomputed grid positions (world-space)
var grid_positions: Array[Vector2] = []


# -------------------------
# Scene references
# -------------------------

@onready var contents: Node2D = $Contents


func _ready():
	_build_grid_positions()


# -------------------------
# Grid setup
# -------------------------

func _build_grid_positions():
	# Build a centered grid around GRID_CENTER
	grid_positions.clear()

	# Offset so grid is centered instead of top-left anchored
	var grid_width := (GRID_COLUMNS - 1) * GRID_SPACING
	var grid_height := (GRID_ROWS - 1) * GRID_SPACING
	var top_left := GRID_CENTER - Vector2(grid_width, grid_height) * 0.5

	for row in range(GRID_ROWS):
		for col in range(GRID_COLUMNS):
			var pos := top_left + Vector2(col, row) * GRID_SPACING
			grid_positions.append(pos)


# -------------------------
# Ingredient handling
# -------------------------

func add_ingredient(item_node: Area2D) -> void:
	if item_node.ingredient_data == null:
		return

	if ingredient_nodes.size() >= grid_positions.size():
		print("Cauldron is full!")
		item_node.snap_back()
		return
	
	# MARK OWNERSHIP
	item_node.in_cauldron = true
	item_node.home_cauldron = self

	# INVENTORY: remove ingredient
	PlayerInventory.remove_item(item_node.ingredient_data)

	# Mark ingredient state
	item_node.in_cauldron = true

	# Store ingredient data
	mix.append(item_node.ingredient_data)
	ingredient_nodes.append(item_node)

	# Reparent visually
	item_node.reparent(contents)

	# IMPORTANT: do NOT disable input_pickable
	item_node.dragging = false

	# Place ingredient in the next grid slot
	var slot_index := ingredient_nodes.size() - 1
	item_node.global_position = grid_positions[slot_index]
	item_node.original_position = item_node.global_position

	item_node.z_index = 5


func remove_ingredient(item_node: Area2D) -> void:
	if not ingredient_nodes.has(item_node):
		return

	# 1. Remove from mix + node tracking
	mix.erase(item_node.ingredient_data)
	ingredient_nodes.erase(item_node)

	# 2. Return to table
	if item_node.home_table:
		item_node.home_table.return_ingredient(item_node)

	# 3. Rebuild remaining cauldron grid
	_reposition_grid()

func _reposition_grid():
	for i in range(ingredient_nodes.size()):
		var node := ingredient_nodes[i]
		node.global_position = grid_positions[i]
		node.original_position = node.global_position


func clear_mix():
	# Clears all ingredient data and visuals (used after crafting)
	mix.clear()

	for node in ingredient_nodes:
		if is_instance_valid(node):
			node.queue_free()

	ingredient_nodes.clear()

# For testing
func debug_print():
	print("--- CAULDRON MIX ---")
	for item in mix:
		print("- ", item.display_name)

	print("--- CAULDRON NODES ---")
	for node in ingredient_nodes:
		print("- ", node.ingredient_data.display_name)
