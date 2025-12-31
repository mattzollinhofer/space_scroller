extends CanvasLayer
## Displays the player's current score in the HUD.
## Shows score in top-right corner with comma-separated thousands format.


## Reference to score label
@onready var _score_label: Label = $Container/ScoreLabel

## Current displayed score
var _current_score: int = 0


func _ready() -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_display(0)


## Update the score display with a new value
func _update_display(score: int) -> void:
	_current_score = score
	if _score_label:
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


## Get the current score (for testing)
func get_score() -> int:
	return _current_score
