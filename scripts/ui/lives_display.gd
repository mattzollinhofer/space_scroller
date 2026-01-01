extends CanvasLayer
## Displays player lives as ship icons at the bottom center of the screen.
## Uses the currently selected character sprite.

## Container for life icons
@onready var _container: HBoxContainer = $Container

## Current displayed lives
var _current_lives: int = 3

## Maximum lives (based on difficulty)
var _max_lives: int = 3

## Size of each ship icon
const ICON_SIZE := Vector2(48, 48)

## Spacing between icons
const ICON_SPACING := 8


func _ready() -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Get starting lives from GameState
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		_max_lives = game_state.get_starting_lives()
		_current_lives = _max_lives

	# Build initial display
	_build_life_icons()

	# Connect to player when ready
	call_deferred("_connect_to_player")


func _connect_to_player() -> void:
	# Find the player in the scene tree
	var player = get_tree().root.get_node_or_null("Main/Player")
	if player:
		if player.has_signal("lives_changed"):
			player.lives_changed.connect(_update_display)
		# Get initial lives
		if player.has_method("get_lives"):
			_update_display(player.get_lives())


## Build life icon sprites based on max lives
func _build_life_icons() -> void:
	# Clear existing icons
	for child in _container.get_children():
		child.queue_free()

	# Get the character texture
	var texture = _get_character_texture()
	if not texture:
		return

	# Create icons for each life
	for i in range(_max_lives):
		var icon = TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.modulate.a = 1.0 if i < _current_lives else 0.3
		_container.add_child(icon)


## Get the character texture from GameState
func _get_character_texture() -> Texture2D:
	var game_state = get_node_or_null("/root/GameState")
	if not game_state:
		return null

	var selected_character = game_state.get_selected_character()
	var texture_path = game_state.get_character_texture_path(selected_character)
	return load(texture_path)


## Update the display based on current lives
func _update_display(lives: int) -> void:
	_current_lives = lives

	var icons = _container.get_children()
	for i in range(icons.size()):
		# Full opacity for remaining lives, faded for lost
		icons[i].modulate.a = 1.0 if i < lives else 0.3


## Rebuild the display (called when difficulty or character changes)
func rebuild() -> void:
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		_max_lives = game_state.get_starting_lives()
	_build_life_icons()
