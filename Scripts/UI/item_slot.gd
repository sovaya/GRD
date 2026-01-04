extends Control

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

func set_item(item: ItemData) -> void:
	if icon == null:
		push_error("ItemSlot icon is null — set_item called too early")
		return

	icon.texture = item.icon
	label.text = item.display_name
