extends Control
## Level selection screen allowing player to choose from available levels.
## Displays level buttons with locked/unlocked states based on progress.

## References to level buttons
@onready var _level1_button: Button = $CenterContainer/VBoxContainer/LevelGrid/Level1Button
@onready var _level2_button: Button = $CenterContainer/VBoxContainer/LevelGrid/Level2Button
@onready var _level3_button: Button = $CenterContainer/VBoxContainer/LevelGrid/Level3Button
@onready var _level4_button: Button = $CenterContainer/VBoxContainer/LevelGrid/Level4Button
@onready var _back_button: Button = $CenterContainer/VBoxContainer/BackButton


func _ready() -> void:
	# Connect button signals
	_level1_button.pressed.connect(_on_level_selected.bind(1))
	_level2_button.pressed.connect(_on_level_selected.bind(2))
	_level3_button.pressed.connect(_on_level_selected.bind(3))
	_level4_button.pressed.connect(_on_level_selected.bind(4))
	_back_button.pressed.connect(_on_back_pressed)

	# Update button states based on unlock status
	_update_button_states()


## Update button enabled/disabled states - all levels are selectable
func _update_button_states() -> void:
	# All levels are always available from level select
	_level1_button.disabled = false
	_update_button_appearance(_level1_button, true)

	_level2_button.disabled = false
	_update_button_appearance(_level2_button, true)

	_level3_button.disabled = false
	_update_button_appearance(_level3_button, true)

	_level4_button.disabled = false
	_update_button_appearance(_level4_button, true)


## Check if a level is unlocked via ScoreManager
func _is_level_unlocked(level_number: int) -> bool:
	if not has_node("/root/ScoreManager"):
		# Default: only Level 1 unlocked
		return level_number == 1

	var score_manager = get_node("/root/ScoreManager")
	if score_manager.has_method("is_level_unlocked"):
		return score_manager.is_level_unlocked(level_number)

	return level_number == 1


## Update button appearance based on locked/unlocked state
func _update_button_appearance(button: Button, unlocked: bool) -> void:
	if unlocked:
		button.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))  # Gold
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))  # White
	else:
		button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))  # Gray
		button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5, 1))


## Handle level button pressed - start game with selected level
func _on_level_selected(level_number: int) -> void:
	# Set selected level in GameState
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		if game_state.has_method("set_selected_level"):
			game_state.set_selected_level(level_number)
		# Clear carried-over lives when starting from level select
		game_state.clear_current_lives()

	# Transition to main game scene
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/main.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")


## Handle back button pressed - return to main menu with transition
func _on_back_pressed() -> void:
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")
