extends CanvasLayer
## Level complete screen that displays when the player finishes the level.
## Pauses the game tree when shown.
## Shows current score, high score, and "NEW HIGH SCORE!" indicator.


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


## Show the level complete screen and pause the game
func show_level_complete() -> void:
	_update_score_display()
	_update_high_score_display()
	visible = true
	# Pause the game tree
	get_tree().paused = true


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
