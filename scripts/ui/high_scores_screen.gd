extends Control
## High Scores screen displaying the top 10 scores with player initials.
## Accessible from the main menu via the High Scores button.

## Reference to the container for score entries
@onready var _score_container: VBoxContainer = $CenterContainer/VBoxContainer/ScoreContainer
@onready var _back_button: Button = $CenterContainer/VBoxContainer/BackButton


func _ready() -> void:
	# Connect back button signal
	_back_button.pressed.connect(_on_back_pressed)

	# Populate the high scores list
	_populate_scores()


## Populate the score list from ScoreManager
func _populate_scores() -> void:
	# Clear existing entries (except any template)
	for child in _score_container.get_children():
		child.queue_free()

	# Get high scores from ScoreManager
	var high_scores: Array = []
	if has_node("/root/ScoreManager"):
		high_scores = get_node("/root/ScoreManager").get_high_scores()

	# Create entries for all 10 slots
	for i in range(10):
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		if i < high_scores.size():
			var entry = high_scores[i]
			var initials = entry.get("initials", "AAA")
			var score = entry.get("score", 0)
			label.text = "%d. %s - %s" % [i + 1, initials, _format_score(score)]
			# Gold color for filled entries
			label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
		else:
			# Placeholder for empty slots
			label.text = "%d. --- - 0" % (i + 1)
			# Dimmed white for empty entries
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))

		label.add_theme_font_size_override("font_size", 48)
		_score_container.add_child(label)


## Format score with thousands separator
func _format_score(score: int) -> String:
	var score_str = str(score)
	var result = ""
	var count = 0

	for i in range(score_str.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = score_str[i] + result
		count += 1

	return result


## Handle back button pressed - return to main menu with transition
func _on_back_pressed() -> void:
	_play_sfx("button_click")
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
