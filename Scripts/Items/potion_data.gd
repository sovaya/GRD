class_name PotionData
extends Resource
# Stores all data related to a potion.
# This resource is what gets crafted, stored, saved, and inspected.
# Scene nodes (Potion.gd) simply *read* from this.

# Display name shown in UI
@export var display_name: String = "Unnamed Potion"

# List of ingredient resources used to create this potion.
# These can be assigned in the editor or via code.
@export var ingredients: Array[IngredientItemData] = []

# Final combined effects of the potion.
# Built from ingredients using rebuild_effects().
# Example:
#   {
#     "damage": 3,
#     "healing": 2
#   }
var effects: Dictionary = {}


# Recalculates the potion's final effects from its ingredients.
# This should be called whenever ingredients change.
func rebuild_effects():
	effects.clear() # Clear previous results so we don't stack repeatedly

	for ingredient in ingredients: # Loop through each ingredient in the potion
		if ingredient == null: # Skip empty slots
			continue
		var effect_data := ingredient.get_effect_value() # Get the ingredient's effect contribution

		# Merge ingredient effects into the potion
		for effect in effect_data.keys():
			# Initialize effect if it doesn't exist yet
			if not effects.has(effect):
				effects[effect] = 0

			# Stack effect values
			effects[effect] += effect_data[effect]
