extends Node2D
## Integration test: Legacy high scores without initials load with "AAA" default
## Tests backwards compatibility: old high scores files that don't have initials_N keys
## should load with "AAA" as the default initials.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"


func _ready() -> void:
	print("=== Test: Legacy High Scores Load with AAA Default ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

	# Create a legacy high scores file WITHOUT initials keys
	_create_legacy_high_scores_file()

	# Get ScoreManager autoload
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# Force reload to read the legacy file
	print("Loading legacy high scores file...")
	score_manager.load_high_scores()

	# Get the loaded high scores
	var high_scores = score_manager.get_high_scores()

	if high_scores.is_empty():
		_fail("No high scores loaded from legacy file")
		return

	print("Loaded %d high scores from legacy file" % high_scores.size())

	# Verify all entries have "AAA" as default initials
	for i in range(high_scores.size()):
		var entry = high_scores[i]
		print("Entry %d: score=%d, initials='%s'" % [i + 1, entry["score"], entry.get("initials", "MISSING")])

		if not entry.has("initials"):
			_fail("Entry %d missing 'initials' key" % (i + 1))
			return

		if entry["initials"] != "AAA":
			_fail("Entry %d initials should be 'AAA' (default), got '%s'" % [i + 1, entry["initials"]])
			return

	# Now verify the high scores screen also shows AAA
	_verify_high_scores_screen()


func _create_legacy_high_scores_file() -> void:
	# Create a ConfigFile with high scores but WITHOUT initials keys
	# This simulates a save file from before the initials feature was added
	var config = ConfigFile.new()

	# Add 3 legacy high score entries (no initials_N keys)
	config.set_value("high_scores", "score_0", 10000)
	config.set_value("high_scores", "date_0", "2025-01-01T12:00:00")
	# NO initials_0 key!

	config.set_value("high_scores", "score_1", 8000)
	config.set_value("high_scores", "date_1", "2025-01-02T12:00:00")
	# NO initials_1 key!

	config.set_value("high_scores", "score_2", 5000)
	config.set_value("high_scores", "date_2", "2025-01-03T12:00:00")
	# NO initials_2 key!

	config.set_value("high_scores", "count", 3)

	# Also add some level unlocks (to test that doesn't break)
	config.set_value("level_unlocks", "level_0", 1)
	config.set_value("level_unlocks", "count", 1)

	config.save(HIGH_SCORE_PATH)
	print("Created legacy high scores file (without initials keys)")


func _verify_high_scores_screen() -> void:
	# Load the high scores screen
	if not ResourceLoader.exists("res://scenes/ui/high_scores_screen.tscn"):
		_fail("high_scores_screen.tscn does not exist")
		return

	var scene = load("res://scenes/ui/high_scores_screen.tscn")
	if scene == null:
		_fail("Failed to load high_scores_screen.tscn")
		return

	var high_scores_screen = scene.instantiate()
	add_child(high_scores_screen)

	# Wait for scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame

	# Find score labels
	var score_labels = _find_score_entry_labels(high_scores_screen)
	print("Found %d score entry labels on screen" % score_labels.size())

	# Check first entry shows "AAA"
	if score_labels.size() < 3:
		_fail("Expected at least 3 score entries but found %d" % score_labels.size())
		return

	var first_entry = score_labels[0].text
	print("First entry on screen: '%s'" % first_entry)

	if not "AAA" in first_entry:
		_fail("First entry should contain 'AAA' but got: %s" % first_entry)
		return

	var second_entry = score_labels[1].text
	print("Second entry on screen: '%s'" % second_entry)

	if not "AAA" in second_entry:
		_fail("Second entry should contain 'AAA' but got: %s" % second_entry)
		return

	print("All legacy scores display with 'AAA' default initials")

	# Clean up
	_cleanup_high_scores_file()
	_pass()


func _find_score_entry_labels(root: Node) -> Array:
	var labels: Array = []
	_collect_score_labels(root, labels)
	return labels


func _collect_score_labels(node: Node, labels: Array) -> void:
	if node is Label:
		var text = node.text
		# Check if this looks like a score entry: "N. XXX - N,NNN"
		if text.length() > 0 and text[0].is_valid_int() and "." in text and " - " in text:
			labels.append(node)

	for child in node.get_children():
		_collect_score_labels(child, labels)


func _cleanup_high_scores_file() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up high scores test file")

	# Reload to clear cached state
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").load_high_scores()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_cleanup_high_scores_file()
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Legacy high scores without initials load with 'AAA' default.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
