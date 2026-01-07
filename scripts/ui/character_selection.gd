extends Control
## Character selection screen allowing player to choose from 5 characters.
## Displays character previews with selection highlighting.
## Also allows difficulty selection (Normal/Hard).

## References to character buttons (set in _ready)
@onready var _blue_blaster_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/BlueBlasterButton
@onready var _space_dragon_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/SpaceDragonButton
@onready var _cosmic_cat_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/CosmicCatButton
@onready var _space_sheep_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/SpaceSheepButton
@onready var _cosmic_hamster_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/CosmicHamsterButton
@onready var _astro_maple_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/AstroMapleButton
@onready var _garfield_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/GarfieldButton
@onready var _declyn_button: Button = $CenterContainer/VBoxContainer/CharacterGrid/DeclynButton
@onready var _back_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/BackButton
@onready var _ok_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/OKButton

## References to difficulty buttons
@onready var _normal_button: Button = $CenterContainer/VBoxContainer/DifficultyContainer/NormalButton
@onready var _hard_button: Button = $CenterContainer/VBoxContainer/DifficultyContainer/HardButton

## Character button references for highlighting
var _character_buttons: Dictionary = {}

## Difficulty button references for highlighting
var _difficulty_buttons: Dictionary = {}


func _ready() -> void:
	# Map character IDs to their buttons
	_character_buttons = {
		GameState.CHARACTER_BLUE_BLASTER: _blue_blaster_button,
		GameState.CHARACTER_SPACE_DRAGON: _space_dragon_button,
		GameState.CHARACTER_COSMIC_CAT: _cosmic_cat_button,
		GameState.CHARACTER_SPACE_SHEEP: _space_sheep_button,
		GameState.CHARACTER_COSMIC_HAMSTER: _cosmic_hamster_button,
		GameState.CHARACTER_ASTRO_MAPLE: _astro_maple_button,
		GameState.CHARACTER_GARFIELD: _garfield_button,
		GameState.CHARACTER_DECLYN: _declyn_button
	}

	# Map difficulty IDs to their buttons
	_difficulty_buttons = {
		GameState.DIFFICULTY_NORMAL: _normal_button,
		GameState.DIFFICULTY_HARD: _hard_button
	}

	# Connect character button signals
	_blue_blaster_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_BLUE_BLASTER))
	_space_dragon_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_SPACE_DRAGON))
	_cosmic_cat_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_COSMIC_CAT))
	_space_sheep_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_SPACE_SHEEP))
	_cosmic_hamster_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_COSMIC_HAMSTER))
	_astro_maple_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_ASTRO_MAPLE))
	_garfield_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_GARFIELD))
	_declyn_button.pressed.connect(_on_character_selected.bind(GameState.CHARACTER_DECLYN))

	# Connect difficulty button signals
	_normal_button.pressed.connect(_on_difficulty_selected.bind(GameState.DIFFICULTY_NORMAL))
	_hard_button.pressed.connect(_on_difficulty_selected.bind(GameState.DIFFICULTY_HARD))

	# Connect navigation buttons
	_back_button.pressed.connect(_on_back_pressed)
	_ok_button.pressed.connect(_on_ok_pressed)

	# Update highlights for currently selected options
	_update_selection_highlight()
	_update_difficulty_highlight()


## Handle character button pressed
func _on_character_selected(character_id: String) -> void:
	GameState.set_selected_character(character_id)
	_update_selection_highlight()


## Handle OK button pressed - confirm selection and return to main menu
func _on_ok_pressed() -> void:
	# Selection is already saved in GameState when character is clicked
	# Just navigate back to main menu
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")


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


## Handle difficulty button pressed
func _on_difficulty_selected(difficulty_id: String) -> void:
	GameState.set_selected_difficulty(difficulty_id)
	_update_difficulty_highlight()


## Update visual highlighting to show selected difficulty
func _update_difficulty_highlight() -> void:
	var selected = GameState.get_selected_difficulty()

	for diff_id in _difficulty_buttons:
		var button: Button = _difficulty_buttons[diff_id]
		if diff_id == selected:
			# Highlight selected difficulty - gold
			button.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))  # Gold
			button.modulate = Color(1, 1, 1, 1)
		else:
			# Dim unselected difficulty
			button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))  # Gray
			button.modulate = Color(0.7, 0.7, 0.7, 1)
