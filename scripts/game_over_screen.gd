extends CanvasLayer
## Game over screen that displays when the player loses all lives.
## Pauses the game tree when shown.


## Reference to score label
@onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel


func _ready() -> void:
	# Start hidden
	visible = false
	# Set process mode to continue running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


## Show the game over screen and pause the game
func show_game_over() -> void:
	_update_score_display()
	visible = true
	# Pause the game tree
	get_tree().paused = true


## Hide the game over screen (for restart functionality, if implemented later)
func hide_game_over() -> void:
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
