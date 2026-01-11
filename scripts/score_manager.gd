extends Node
## ScoreManager autoload singleton for tracking player score.
## Connects to enemy died signals to award points.
## Emits score_changed signal for UI updates.
## Handles high score persistence using ConfigFile.
## Also manages level unlock state.

## Emitted when score changes
signal score_changed(new_score: int)

## Emitted when a new high score is achieved
signal new_high_score(score: int)

## Emitted when a level is unlocked
signal level_unlocked(level_number: int)

## Current score for the active game session
var _current_score: int = 0

## High scores list (array of dictionaries with "score", "date", and "initials" keys)
var _high_scores: Array = []

## Unlocked levels (array of level numbers, Level 1 always unlocked)
var _unlocked_levels: Array = [1]

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
## initials: 3-letter player initials (defaults to "AAA")
func save_high_score(initials: String = "AAA") -> void:
	if _current_score <= 0:
		return

	if not qualifies_for_top_10():
		return

	var is_new_top_score: bool = is_new_high_score()
	var score_to_submit: int = _current_score

	# Create new entry with initials
	var entry: Dictionary = {
		"score": _current_score,
		"date": Time.get_datetime_string_from_system(true),
		"initials": initials
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

	# Submit to Firebase (fire-and-forget, silent failure)
	if has_node("/root/FirebaseService"):
		get_node("/root/FirebaseService").submit_score(score_to_submit, initials)

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


## Check if a level is unlocked
func is_level_unlocked(level_number: int) -> bool:
	# Level 1 is always unlocked
	if level_number == 1:
		return true
	return level_number in _unlocked_levels


## Unlock a level
func unlock_level(level_number: int) -> void:
	if level_number in _unlocked_levels:
		return
	_unlocked_levels.append(level_number)
	_unlocked_levels.sort()
	_save_to_file()
	level_unlocked.emit(level_number)


## Reset level unlocks (for testing)
func reset_level_unlocks() -> void:
	_unlocked_levels = [1]
	_save_to_file()


## Get the highest unlocked level number
func get_highest_unlocked_level() -> int:
	if _unlocked_levels.is_empty():
		return 1
	return _unlocked_levels.max()


## Save high scores and level unlocks to file using ConfigFile
func _save_to_file() -> void:
	var config = ConfigFile.new()

	# Save high scores
	for i in range(_high_scores.size()):
		var entry = _high_scores[i]
		config.set_value("high_scores", "score_%d" % i, entry["score"])
		config.set_value("high_scores", "date_%d" % i, entry["date"])
		config.set_value("high_scores", "initials_%d" % i, entry.get("initials", "AAA"))

	config.set_value("high_scores", "count", _high_scores.size())

	# Save level unlocks
	for i in range(_unlocked_levels.size()):
		config.set_value("level_unlocks", "level_%d" % i, _unlocked_levels[i])

	config.set_value("level_unlocks", "count", _unlocked_levels.size())

	config.save(HIGH_SCORE_PATH)


## Load high scores and level unlocks from file
func load_high_scores() -> void:
	_high_scores.clear()
	_unlocked_levels = [1]  # Level 1 always unlocked

	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		return

	var config = ConfigFile.new()
	var error = config.load(HIGH_SCORE_PATH)
	if error != OK:
		return

	# Load high scores
	var count: int = config.get_value("high_scores", "count", 0)

	for i in range(count):
		var score: int = config.get_value("high_scores", "score_%d" % i, 0)
		var date: String = config.get_value("high_scores", "date_%d" % i, "")
		var initials: String = config.get_value("high_scores", "initials_%d" % i, "AAA")
		if score > 0:
			_high_scores.append({
				"score": score,
				"date": date,
				"initials": initials
			})

	# Ensure sorted after loading
	_sort_high_scores()

	# Load level unlocks
	var unlock_count: int = config.get_value("level_unlocks", "count", 0)

	for i in range(unlock_count):
		var level_num: int = config.get_value("level_unlocks", "level_%d" % i, 0)
		if level_num > 0 and level_num not in _unlocked_levels:
			_unlocked_levels.append(level_num)

	_unlocked_levels.sort()
