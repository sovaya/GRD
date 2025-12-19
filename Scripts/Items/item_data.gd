class_name ItemData
extends Resource
# Base data class for any item-like thing in the game.
# This is a pure data container — no scene logic.

@export var display_name: String
@export var description: String
@export var icon: Texture

# Numerical strength of the item's effect
# Example: damage = 3, healing = 5
@export var amount: int

# Type of effect this item provides
# Example values: "damage", "healing"
@export var effect: String

# Returns the effect this item contributes, formatted as a dictionary.
# This allows different systems (potions, crafting, combat)
# to combine effects in a generic way.

# Example return value:
#   { "damage": 3 }
func get_effect_value() -> Dictionary:
	return {
		effect: amount
	}
