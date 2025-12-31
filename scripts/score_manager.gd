extends Node
## ScoreManager autoload singleton for tracking player score.
## Connects to enemy died signals to award points.
## Emits score_changed signal for UI updates.
## Handles high score persistence using ConfigFile.

## Emitted when score changes
signal score_changed(new_score: int)

## Emitted when a new high score is achieved
signal new_high_score(score: int)

## Current score for the active game session
var _current_score: int = 0

## High scores list (array of dictionaries with "score" and "date" keys)
var _high_scores: Array = []

## Maximum number of high scores to store
const MAX_HIGH_SCORES: int = 10

## Path to high scores file
const HIGH_SCORE_PATH: String = "user://high_scores.cfg"

## Point values for different enemy types
const POINTS_STATIONARY_ENEMY: int = 100
const POINTS_PATROL_ENEMY: int = 200

## Bonus point values
const POINTS_UFO_FRIEND: int = 500
const POINTS_LEVEL_COMPLETE: int = 5000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_scores()


## Get the current score
func get_score() -> int:
	return _current_score


## Add points to the score
func add_points(amount: int) -> void:
	_current_score += amount
	score_changed.emit(_current_score)


## Reset score to zero (called on new game start)
func reset_score() -> void:
	_current_score = 0
	score_changed.emit(_current_score)


## Award points for killing an enemy (called by whoever connects to enemy.died)
## enemy_type should be the enemy node to check if it's a PatrolEnemy
func award_enemy_kill(enemy: Node) -> void:
	if enemy is PatrolEnemy:
		add_points(POINTS_PATROL_ENEMY)
	else:
		add_points(POINTS_STATIONARY_ENEMY)


## Award bonus points for collecting a UFO Friend pickup
func award_ufo_friend_bonus() -> void:
	add_points(POINTS_UFO_FRIEND)


## Award bonus points for completing a level
func award_level_complete_bonus() -> void:
	add_points(POINTS_LEVEL_COMPLETE)


## Get the highest score from the high scores list
func get_high_score() -> int:
	if _high_scores.is_empty():
		return 0
	return _high_scores[0]["score"]


## Get the full list of high scores
func get_high_scores() -> Array:
	return _high_scores.duplicate()


## Check if current score qualifies as a new #1 high score
## Returns true only if current score beats the existing top score
func is_new_high_score() -> bool:
	if _current_score <= 0:
		return false
	if _high_scores.is_empty():
		return true
	return _current_score > _high_scores[0]["score"]


## Check if current score qualifies for the top 10 list
func qualifies_for_top_10() -> bool:
	if _current_score <= 0:
		return false
	if _high_scores.size() < MAX_HIGH_SCORES:
		return true
	return _current_score > _high_scores[MAX_HIGH_SCORES - 1]["score"]


## Save current score to high scores if it qualifies
func save_high_score() -> void:
	if _current_score <= 0:
		return

	if not qualifies_for_top_10():
		return

	var is_new_top_score: bool = is_new_high_score()

	# Create new entry
	var entry: Dictionary = {
		"score": _current_score,
		"date": Time.get_datetime_string_from_system(true)
	}

	# Add to list
	_high_scores.append(entry)

	# Sort descending by score, with older duplicates removed first
	_sort_high_scores()

	# Trim to max entries
	while _high_scores.size() > MAX_HIGH_SCORES:
		_high_scores.pop_back()

	# Save to file
	_save_to_file()

	# Emit signal if this is a new top high score
	if is_new_top_score:
		new_high_score.emit(_current_score)


## Sort high scores descending by score, oldest duplicates dropped first
func _sort_high_scores() -> void:
	# Sort by score descending, then by date ascending (newer scores kept)
	_high_scores.sort_custom(func(a, b):
		if a["score"] != b["score"]:
			return a["score"] > b["score"]
		# For same scores, keep newer one (later date is "greater")
		return a["date"] > b["date"]
	)


## Save high scores to file using ConfigFile
func _save_to_file() -> void:
	var config = ConfigFile.new()

	for i in range(_high_scores.size()):
		var entry = _high_scores[i]
		config.set_value("high_scores", "score_%d" % i, entry["score"])
		config.set_value("high_scores", "date_%d" % i, entry["date"])

	config.set_value("high_scores", "count", _high_scores.size())
	config.save(HIGH_SCORE_PATH)


## Load high scores from file
func load_high_scores() -> void:
	_high_scores.clear()

	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		return

	var config = ConfigFile.new()
	var error = config.load(HIGH_SCORE_PATH)
	if error != OK:
		return

	var count: int = config.get_value("high_scores", "count", 0)

	for i in range(count):
		var score: int = config.get_value("high_scores", "score_%d" % i, 0)
		var date: String = config.get_value("high_scores", "date_%d" % i, "")
		if score > 0:
			_high_scores.append({
				"score": score,
				"date": date
			})

	# Ensure sorted after loading
	_sort_high_scores()
