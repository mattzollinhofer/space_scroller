extends CanvasLayer
## Displays the player's current score in the HUD.
## Shows score in top-right corner with comma-separated thousands format.
## Connects to ScoreManager to receive score updates.


## Reference to score label
@onready var _score_label: Label = $Container/ScoreLabel

## Current displayed score
var _current_score: int = 0


func _ready() -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_display(0)
	_connect_to_score_manager()


## Connect to ScoreManager autoload for score updates
func _connect_to_score_manager() -> void:
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_signal("score_changed"):
			score_manager.score_changed.connect(_on_score_changed)
			# Sync with current score in case we connected late
			if score_manager.has_method("get_score"):
				_update_display(score_manager.get_score())


## Called when score changes in ScoreManager
func _on_score_changed(new_score: int) -> void:
	_update_display(new_score)


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
