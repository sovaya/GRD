extends Area2D
# Represents a single ingredient on the table that can be dragged around

# The data resource that defines this ingredient (icon, name, etc.)
@export var ingredient_data: IngredientItemData

var dragging := false # Whether the player is currently dragging this ingredient
var drag_offset := Vector2.ZERO # Offset so the ingredient doesn't "snap" its center to the mouse
var original_position := Vector2.ZERO # Position to return to if we cancel the drag

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

			# Save original position in case we need to snap back
			original_position = global_position

			# Bring the ingredient visually to the front
			z_index = 10
		else:
			# Stop dragging
			dragging = false
			z_index = 0
			snap_back()


func _process(_delta):
	# While dragging, follow the mouse
	if dragging:
		global_position = get_global_mouse_position() + drag_offset


func snap_back():
	# Return ingredient to its previous position
	global_position = original_position
