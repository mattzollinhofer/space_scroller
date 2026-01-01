extends CanvasLayer
## Game over screen that displays when the player loses all lives.
## Pauses the game tree when shown.
## Shows current score, high score, and "NEW HIGH SCORE!" indicator.
## Provides Main Menu button to return to the main menu.


## Reference to score label
@onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel

## Reference to high score label
@onready var _high_score_label: Label = $CenterContainer/VBoxContainer/HighScoreLabel

## Reference to new high score indicator
@onready var _new_high_score_label: Label = $CenterContainer/VBoxContainer/NewHighScoreLabel


func _ready() -> void:
	# Start hidden
	visible = false
	# Set process mode to continue running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


## Show the game over screen and pause the game
func show_game_over() -> void:
	_update_score_display()
	_update_high_score_display()
	visible = true
	_play_sfx("game_over")
	# Pause the game tree
	get_tree().paused = true


## Hide the game over screen (for restart functionality, if implemented later)
func hide_game_over() -> void:
	visible = false
	get_tree().paused = false


## Handle Main Menu button pressed - return to main menu with transition
func _on_main_menu_button_pressed() -> void:
	# Unpause the game tree before changing scene
	get_tree().paused = false
	# Clear carried-over lives when returning to main menu
	if has_node("/root/GameState"):
		get_node("/root/GameState").clear_current_lives()
	# Stop music before returning to menu
	_stop_gameplay_music()
	# Navigate to main menu with transition
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")


## Stop gameplay music via AudioManager
func _stop_gameplay_music() -> void:
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("stop_music"):
			audio_manager.stop_music()


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
