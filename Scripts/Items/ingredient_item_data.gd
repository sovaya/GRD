class_name IngredientItemData
extends ItemData

# Represents an ingredient used in potion-making.
# Currently identical to ItemData, but exists as its own type
# so we can:
# - Filter ingredients from other items
# - Add ingredient-only properties later (rarity, tags, color, etc.)

# To add a new ingredient:
# Right click "Ingredients" folder > Create New > Resource > ItemData > (Name your new ingredient) > Save
# Once you create a new item, you can double click it and change its name/desc in the Inspector tab.
