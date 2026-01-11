extends CanvasLayer
## Level complete screen that displays when the player finishes the level.
## Pauses the game tree when shown.
## Shows current score, high score, and "NEW HIGH SCORE!" indicator.
## Shows initials entry UI when score qualifies for top 10.
## Unlocks the next level when shown.


## Reference to score label
@onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel

## Reference to high score label
@onready var _high_score_label: Label = $CenterContainer/VBoxContainer/HighScoreLabel

## Reference to new high score indicator
@onready var _new_high_score_label: Label = $CenterContainer/VBoxContainer/NewHighScoreLabel

## Reference to initials entry component
@onready var _initials_entry: Control = $CenterContainer/VBoxContainer/InitialsEntry

## Reference to next level button
@onready var _next_level_button: Button = $CenterContainer/VBoxContainer/NextLevelButton

## Reference to main menu button
@onready var _main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton

## Current level number (set by LevelManager before showing)
var current_level: int = 1

## Maximum level number
const MAX_LEVEL: int = 6

## Whether we're waiting for initials entry
var _awaiting_initials: bool = false

## Stored initials for display
var _player_initials: String = "AAA"


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
	# Connect initials confirmed signal
	if _initials_entry and _initials_entry.has_signal("initials_confirmed"):
		_initials_entry.initials_confirmed.connect(_on_initials_confirmed)


## Set the current level number
func set_current_level(level_number: int) -> void:
	current_level = level_number


## Show the level complete screen and pause the game
func show_level_complete() -> void:
	_update_score_display()
	_unlock_next_level()

	# Only show initials entry on final level (game complete)
	# For mid-game level completions, just show score normally
	var is_final_level: bool = current_level >= MAX_LEVEL
	var qualifies: bool = false

	if is_final_level and has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("qualifies_for_top_10"):
			qualifies = score_manager.qualifies_for_top_10()

	if qualifies:
		# Show initials entry, hide other elements until confirmed
		_awaiting_initials = true
		if _initials_entry:
			_initials_entry.visible = true
			_initials_entry.show_entry()
		if _next_level_button:
			_next_level_button.visible = false
		if _main_menu_button:
			_main_menu_button.visible = false
		# Hide score labels to avoid overlap with initials entry
		if _score_label:
			_score_label.visible = false
		if _high_score_label:
			_high_score_label.visible = false
		# Show new high score indicator if it's the top score
		_show_new_high_score_indicator()
	else:
		# No initials needed, just update display normally
		_awaiting_initials = false
		if _initials_entry:
			_initials_entry.visible = false
		if _score_label:
			_score_label.visible = true
		if _high_score_label:
			_high_score_label.visible = true
		_update_high_score_display()
		_update_buttons()

	visible = true
	# Pause the game tree
	get_tree().paused = true


## Called when player confirms their initials
func _on_initials_confirmed(initials: String) -> void:
	_player_initials = initials
	_awaiting_initials = false

	# Save the score with initials
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("save_high_score"):
			score_manager.save_high_score(initials)

	# Hide initials entry, show score labels again
	if _initials_entry:
		_initials_entry.visible = false
	if _score_label:
		_score_label.visible = true
	if _high_score_label:
		_high_score_label.visible = true

	# Update high score display with initials
	_update_high_score_display_with_initials()

	# Show buttons
	_update_buttons()

	_play_sfx("button_click")


## Show the new high score indicator if applicable
func _show_new_high_score_indicator() -> void:
	if not has_node("/root/ScoreManager"):
		return

	var score_manager = get_node("/root/ScoreManager")
	var is_new: bool = false
	if score_manager.has_method("is_new_high_score"):
		is_new = score_manager.is_new_high_score()

	if _new_high_score_label:
		_new_high_score_label.visible = is_new


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
		# Save sidekick state to carry over to next level
		_save_sidekick_state(game_state)

	# Score persists across levels (not reset here)

	get_tree().change_scene_to_file("res://scenes/main.tscn")


## Save sidekick state to GameState for next level
func _save_sidekick_state(game_state: Node) -> void:
	var sidekicks = get_tree().get_nodes_in_group("sidekick")
	if sidekicks.size() > 0:
		var sidekick = sidekicks[0]
		var sprite_path = ""
		if sidekick.has_method("get_sprite_path"):
			sprite_path = sidekick.get_sprite_path()
		game_state.set_sidekick_state(true, sprite_path)
	else:
		game_state.set_sidekick_state(false)


## Handle main menu button press
func _on_main_menu_pressed() -> void:
	# Unpause before transitioning
	get_tree().paused = false
	visible = false
	# Clear carried-over state when returning to main menu
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		game_state.clear_current_lives()
		game_state.clear_sidekick_state()
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


## Update the high score label to show existing high score (before initials entry)
func _update_existing_high_score_display() -> void:
	if not has_node("/root/ScoreManager"):
		return

	var score_manager = get_node("/root/ScoreManager")

	# Show the existing high score (without saving current score yet)
	if _high_score_label and score_manager.has_method("get_high_score"):
		var high_score: int = score_manager.get_high_score()
		_high_score_label.text = "HIGH SCORE: %s" % _format_number(high_score)


## Update the high score label and new high score indicator (for non-qualifying scores)
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


## Update the high score label with initials included
func _update_high_score_display_with_initials() -> void:
	if not has_node("/root/ScoreManager"):
		return

	var score_manager = get_node("/root/ScoreManager")

	# Update high score label with initials
	if _high_score_label and score_manager.has_method("get_high_score"):
		var high_score: int = score_manager.get_high_score()
		_high_score_label.text = "HIGH SCORE: %s - %s" % [_player_initials, _format_number(high_score)]


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


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
