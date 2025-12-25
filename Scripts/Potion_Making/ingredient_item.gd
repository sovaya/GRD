extends Area2D
# Represents a single ingredient on the table that can be dragged around

# The data resource that defines this ingredient (icon, name, etc.)
@export var ingredient_data: IngredientItemData

var dragging := false # Whether the player is currently dragging this ingredient
var drag_offset := Vector2.ZERO # Offset so the ingredient doesn't "snap" its center to the mouse
var original_position := Vector2.ZERO # Position to return to if we cancel the drag

var in_cauldron := false # Whether this ingredient is currently inside the cauldron
var home_table: Area2D # Reference to the table that spawned this ingredient
var home_cauldron: Area2D = null

# Reference to the sprite that displays the ingredient icon
@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	input_pickable = true # Allows this Area2D to receive mouse input
	original_position = global_position # Store starting position so we can snap back later

	# Assign the icon from the ingredient data
	if ingredient_data and ingredient_data.icon:
		sprite.texture = ingredient_data.icon
	# Scale down large icons
	sprite.scale = Vector2(0.5, 0.5)


func _input_event(_viewport, event, _shape_idx):
	# Handle left mouse button clicks
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			dragging = true # Start dragging

			# Remember offset between mouse and object position
			drag_offset = global_position - get_global_mouse_position()

			# Bring the ingredient visually to the front
			z_index = 10
		else:
			# Stop dragging
			dragging = false
			z_index = 0
			_handle_drop()

func _handle_drop():
	# Find overlapping areas
	var dropped := false
	for area in get_overlapping_areas():
		# Dropped into cauldron
		if area.is_in_group("cauldron") and not in_cauldron:
			area.add_ingredient(self)
			dropped = true
			break

		# Dropped back onto table from cauldron
		if area.is_in_group("table") and in_cauldron:
			if home_cauldron:
				home_cauldron.remove_ingredient(self)
				dropped = true
				break

	# If none matched, snap back
	if not dropped:
		snap_back()


func _process(_delta):
	# While dragging, follow the mouse
	if dragging:
		global_position = get_global_mouse_position() + drag_offset


func snap_back():
	# Only snap back if not in cauldron
	if not in_cauldron:
		global_position = original_position
