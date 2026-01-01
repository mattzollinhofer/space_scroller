extends CanvasLayer
## Level complete screen that displays when the player finishes the level.
## Pauses the game tree when shown.
## Shows current score, high score, and "NEW HIGH SCORE!" indicator.
## Unlocks the next level when shown.


## Reference to score label
@onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel

## Reference to high score label
@onready var _high_score_label: Label = $CenterContainer/VBoxContainer/HighScoreLabel

## Reference to new high score indicator
@onready var _new_high_score_label: Label = $CenterContainer/VBoxContainer/NewHighScoreLabel

## Reference to next level button
@onready var _next_level_button: Button = $CenterContainer/VBoxContainer/NextLevelButton

## Reference to main menu button
@onready var _main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton

## Current level number (set by LevelManager before showing)
var current_level: int = 1

## Maximum level number
const MAX_LEVEL: int = 3


func _ready() -> void:
	# Start hidden
	visible = false
	# Set process mode to continue running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Connect button signals
	if _next_level_button:
		_next_level_button.pressed.connect(_on_next_level_pressed)
	if _main_menu_button:
		_main_menu_button.pressed.connect(_on_main_menu_pressed)


## Set the current level number
func set_current_level(level_number: int) -> void:
	current_level = level_number


## Show the level complete screen and pause the game
func show_level_complete() -> void:
	_update_score_display()
	_update_high_score_display()
	_unlock_next_level()
	_update_buttons()
	visible = true
	# Pause the game tree
	get_tree().paused = true


## Update which button is shown based on whether there's a next level
func _update_buttons() -> void:
	var has_next_level: bool = current_level < MAX_LEVEL
	if _next_level_button:
		_next_level_button.visible = has_next_level
	if _main_menu_button:
		_main_menu_button.visible = not has_next_level


## Handle next level button press
func _on_next_level_pressed() -> void:
	# Unpause before transitioning
	get_tree().paused = false
	visible = false

	# Set the next level in GameState and reload main scene
	var next_level: int = current_level + 1
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		if game_state.has_method("set_selected_level"):
			game_state.set_selected_level(next_level)
		# Save player's current lives to carry over to next level
		var player = get_tree().root.get_node_or_null("Main/Player")
		if player and player.has_method("get_lives"):
			game_state.set_current_lives(player.get_lives())

	# Reset score for new level
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("reset_score"):
			score_manager.reset_score()

	get_tree().change_scene_to_file("res://scenes/main.tscn")


## Handle main menu button press
func _on_main_menu_pressed() -> void:
	# Unpause before transitioning
	get_tree().paused = false
	visible = false
	# Clear carried-over lives when returning to main menu
	if has_node("/root/GameState"):
		get_node("/root/GameState").clear_current_lives()
	# Stop music before returning to menu
	_stop_gameplay_music()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


## Stop gameplay music via AudioManager
func _stop_gameplay_music() -> void:
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("stop_music"):
			audio_manager.stop_music()


## Hide the level complete screen (for next level functionality, if implemented later)
func hide_level_complete() -> void:
	visible = false
	get_tree().paused = false


## Update the score label with current score from ScoreManager
func _update_score_display() -> void:
	if not _score_label:
		return

	var score: int = 0
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("get_score"):
			score = score_manager.get_score()

	_score_label.text = "SCORE: %s" % _format_number(score)


## Update the high score label and new high score indicator
func _update_high_score_display() -> void:
	if not has_node("/root/ScoreManager"):
		return

	var score_manager = get_node("/root/ScoreManager")

	# Check if this is a new high score before saving
	var is_new: bool = false
	if score_manager.has_method("is_new_high_score"):
		is_new = score_manager.is_new_high_score()

	# Save the score (which may update the high score)
	if score_manager.has_method("save_high_score"):
		score_manager.save_high_score()

	# Update high score label
	if _high_score_label and score_manager.has_method("get_high_score"):
		var high_score: int = score_manager.get_high_score()
		_high_score_label.text = "HIGH SCORE: %s" % _format_number(high_score)

	# Show/hide new high score indicator
	if _new_high_score_label:
		_new_high_score_label.visible = is_new


## Unlock the next level after completing current level
func _unlock_next_level() -> void:
	if not has_node("/root/ScoreManager"):
		return

	var score_manager = get_node("/root/ScoreManager")

	# Unlock the next level (current_level + 1)
	var next_level: int = current_level + 1
	if score_manager.has_method("unlock_level"):
		score_manager.unlock_level(next_level)


## Format number with comma-separated thousands
func _format_number(number: int) -> String:
	var str_num = str(number)
	var result = ""
	var count = 0

	for i in range(str_num.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_num[i] + result
		count += 1

	return result
