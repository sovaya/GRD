extends Control

@onready var potions_grid := $VBoxContainer/PotionsGrid
@onready var ingredients_grid := $VBoxContainer/IngredientsGrid

@export var item_slot_scene: PackedScene

func refresh():
	_clear_grid(potions_grid)
	_clear_grid(ingredients_grid)

	for potion in PlayerInventory.get_potions():
		_add_item_slot(potions_grid, potion)

	for ingredient in PlayerInventory.get_ingredients():
		_add_item_slot(ingredients_grid, ingredient)

func _add_item_slot(grid: GridContainer, item: ItemData):
	var slot = item_slot_scene.instantiate()
	grid.add_child(slot)        # ENTERS SCENE TREE
	slot.set_item(item)         # @onready vars now exist

func _clear_grid(grid: GridContainer):
	for child in grid.get_children():
		child.queue_free()
