extends Control
## High Scores screen displaying the top 10 scores with player initials.
## Accessible from the main menu via the High Scores button.
## Shows local scores instantly, then upgrades to the global online leaderboard.

## Reference to the container for score entries
@onready var _score_container: VBoxContainer = $CenterContainer/VBoxContainer/ScoreContainer
@onready var _back_button: Button = $CenterContainer/VBoxContainer/BackButton
@onready var _title_label: Label = $CenterContainer/VBoxContainer/TitleLabel


func _ready() -> void:
	# Connect back button signal
	_back_button.pressed.connect(_on_back_pressed)

	# Show local scores immediately so the screen works offline and without delay
	_populate_scores(_local_high_scores())

	# Then upgrade to the global leaderboard if it can be fetched
	_fetch_global_scores()


## Get the locally stored high scores from ScoreManager
func _local_high_scores() -> Array:
	if has_node("/root/ScoreManager"):
		return get_node("/root/ScoreManager").get_high_scores()
	return []


## Request the global leaderboard from Firebase (silent, fire-and-forget)
func _fetch_global_scores() -> void:
	if not has_node("/root/FirebaseService"):
		return
	get_node("/root/FirebaseService").fetch_top_scores(10, _on_global_scores_fetched)


## Handle the global leaderboard fetch result. A non-empty result replaces the
## displayed scores; an empty result (offline, timeout, or unconfigured backend)
## leaves the local scores in place.
func _on_global_scores_fetched(scores: Array) -> void:
	if scores.is_empty():
		return
	_populate_scores(scores)
	_title_label.text = "Global High Scores"


## Populate the score list from the given high scores array
func _populate_scores(high_scores: Array) -> void:
	# Clear existing entries (except any template)
	for child in _score_container.get_children():
		child.queue_free()

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
