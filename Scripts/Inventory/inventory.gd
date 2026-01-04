extends Node
class_name Inventory
# Global inventory storing all items the player owns.
# This is a DATA container, not a UI.

###### DEBUG ONLY

# All items the player currently owns
var items: Array[ItemData] = []


func _ready():
	# -------------------------
	# TEMP: Starting items for testing
	# Remove once loot/rewards are implemented
	# -------------------------
	items = [
		#preload("res://Resources/Items/Ingredients/Flower.tres"),
		#preload("res://Resources/Items/Ingredients/Frog_Leg.tres"),
		#preload("res://Resources/Items/Ingredients/Mushroom.tres"),
		#preload("res://Resources/Items/Ingredients/Wolf_Claw.tres"),
	]

	print("Inventory initialized with:", items)


# List of all items the player has
# var items: Array[ItemData] = [] #commented out for debugging


# Adds an item to the inventory
func add_item(item: ItemData) -> void:
	if item == null:
		return
	items.append(item)
	PlayerInventory.debug_print()


# Removes one instance of an item
func remove_item(item: ItemData) -> void:
	items.erase(item)
	PlayerInventory.debug_print()


# Returns all ingredients currently owned
func get_ingredients() -> Array[IngredientItemData]:
	var result: Array[IngredientItemData] = []

	for item in items:
		if item is IngredientItemData:
			result.append(item)

	return result

func get_potions() -> Array[PotionData]:
	var result: Array[PotionData] = []
	for item in items:
		if item is PotionData:
			result.append(item)
	return result


# TEMP: Debug starter inventory
func debug_fill():
	items.clear()
	items.append(preload("res://Resources/Items/Ingredients/Flower.tres"))
	items.append(preload("res://Resources/Items/Ingredients/Frog_Leg.tres"))
	items.append(preload("res://Resources/Items/Ingredients/Mushroom.tres"))
	items.append(preload("res://Resources/Items/Ingredients/Wolf_Claw.tres"))

# For testing.
func debug_print():
	print("--- INVENTORY ---")
	for item in items:
		print("- ", item.display_name)
