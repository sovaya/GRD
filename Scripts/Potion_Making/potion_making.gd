extends Node2D

func _on_mix_button_pressed():
	# Find the first cauldron in the scene
	var cauldron := get_tree().get_first_node_in_group("cauldron")
	if cauldron == null:
		push_error("No cauldron found in the scene!")
		return

	# Create a potion from ingredients
	var potion: PotionData = cauldron.mix_into_potion()
	if potion == null:
		print("Nothing to mix!")
		return

	# Add the new potion to inventory
	PlayerInventory.add_item(potion)

	# Optional: print effect descriptions
	print("Crafted potion:", potion.display_name)
	for effect in potion.effects.keys():
		print("  +", potion.effects[effect], effect)
