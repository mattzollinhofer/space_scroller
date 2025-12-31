extends Control
## Character selection screen allowing player to choose from 3 characters.
## Displays character previews with selection highlighting.

## References to character buttons (set in _ready)
@onready var _blue_blaster_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/BlueBlasterButton
@onready var _space_dragon_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/SpaceDragonButton
@onready var _cosmic_cat_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/CosmicCatButton
@onready var _back_button: Button = $CenterContainer/VBoxContainer/BackButton

## Character button references for highlighting
var _character_buttons: Dictionary = {}


func _ready() -> void:
	# Map character IDs to their buttons
	_character_buttons = {
		GameState.CHARACTER_BLUE_BLASTER: _blue_blaster_button,
		GameState.CHARACTER_SPACE_DRAGON: _space_dragon_button,
		GameState.CHARACTER_COSMIC_CAT: _cosmic_cat_button
	}

	# Connect button signals
	_blue_blaster_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_BLUE_BLASTER))
	_space_dragon_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_SPACE_DRAGON))
	_cosmic_cat_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_COSMIC_CAT))
	_back_button.pressed.connect(_on_back_pressed)

	# Update highlight for currently selected character
	_update_selection_highlight()


## Handle character button pressed
func _on_character_selected(character_id: String) -> void:
	GameState.set_selected_character(character_id)
	_update_selection_highlight()


## Handle back button pressed - return to main menu with transition
func _on_back_pressed() -> void:
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")


## Update visual highlighting to show selected character
func _update_selection_highlight() -> void:
	var selected = GameState.get_selected_character()

	for char_id in _character_buttons:
		var button: Button = _character_buttons[char_id]
		if char_id == selected:
			# Highlight selected character - gold border/color
			button.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))  # Gold
			button.modulate = Color(1, 1, 1, 1)
		else:
			# Dim unselected characters
			button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))  # Gray
			button.modulate = Color(0.7, 0.7, 0.7, 1)
