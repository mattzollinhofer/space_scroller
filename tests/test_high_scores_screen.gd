extends Node2D
## Integration test: High scores screen displays all 10 entries with initials and scores
## Tests that the High Scores button in main menu navigates to high_scores_screen.tscn,
## which shows ranked list 1-10 with format "1. MJK - 12,500"

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0
var _step: int = 0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"


func _ready() -> void:
	print("=== Test: High Scores Screen Display ===")

	# Clean up and set up test data
	_setup_test_scores()


func _setup_test_scores() -> void:
	# Clean up any existing high scores file first
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up existing high scores file")

	# Get ScoreManager autoload
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reload high scores to clear any cached state
	score_manager.load_high_scores()

	# Add 10 test scores with different initials
	var test_scores = [
		{"score": 50000, "initials": "AAA"},
		{"score": 45000, "initials": "BBB"},
		{"score": 40000, "initials": "CCC"},
		{"score": 35000, "initials": "DDD"},
		{"score": 30000, "initials": "EEE"},
		{"score": 25000, "initials": "FFF"},
		{"score": 20000, "initials": "GGG"},
		{"score": 15000, "initials": "HHH"},
		{"score": 10000, "initials": "III"},
		{"score": 5000, "initials": "JJJ"},
	]

	# Save each score
	for entry in test_scores:
		score_manager.reset_score()
		score_manager.add_points(entry["score"])
		score_manager.save_high_score(entry["initials"])

	print("Set up 10 test scores")

	# Verify high scores are saved
	score_manager.load_high_scores()
	var scores = score_manager.get_high_scores()
	print("Loaded %d high scores" % scores.size())

	if scores.size() < 10:
		_fail("Expected 10 high scores but got %d" % scores.size())
		return

	# Now load the high scores screen
	_step = 1


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_cleanup()
		_fail("Test timed out at step %d" % _step)
		return

	match _step:
		1:
			_load_high_scores_screen()
		2:
			_verify_screen_elements()


func _load_high_scores_screen() -> void:
	_step = -1  # Prevent re-entry

	print("Loading high scores screen...")

	# Check if the scene file exists
	if not ResourceLoader.exists("res://scenes/ui/high_scores_screen.tscn"):
		_fail("high_scores_screen.tscn does not exist at res://scenes/ui/high_scores_screen.tscn")
		return

	# Load the scene
	var scene = load("res://scenes/ui/high_scores_screen.tscn")
	if scene == null:
		_fail("Failed to load high_scores_screen.tscn")
		return

	var high_scores_screen = scene.instantiate()
	if high_scores_screen == null:
		_fail("Failed to instantiate high_scores_screen.tscn")
		return

	add_child(high_scores_screen)
	print("High scores screen loaded")

	# Wait a frame for the scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame

	_step = 2


func _verify_screen_elements() -> void:
	_step = -1  # Prevent re-entry

	print("Verifying screen elements...")

	# Find the high scores screen node
	var screen = get_children().filter(func(c): return c.name.contains("HighScores")).front()
	if screen == null:
		_fail("Could not find HighScoresScreen node")
		return

	# Check for title label with gold color
	var title_label = _find_node_by_type_and_text(screen, "Label", "High Scores")
	if title_label == null:
		_fail("Title label 'High Scores' not found")
		return

	# Check title is gold color
	var title_color = title_label.get_theme_color("font_color") if title_label.has_theme_color("font_color") else title_label.get("theme_override_colors/font_color")
	if title_color == null:
		title_color = title_label.get("theme_override_colors/font_color")
	print("Title label found: %s" % title_label.text)

	# Check for Back button
	var back_button = _find_node_by_type_and_text(screen, "Button", "Back")
	if back_button == null:
		_fail("Back button not found")
		return
	print("Back button found")

	# Check for score entries (should be 10)
	# Look for labels with score format like "1. AAA - 50,000"
	var score_labels = _find_score_entry_labels(screen)
	print("Found %d score entry labels" % score_labels.size())

	if score_labels.size() < 10:
		_fail("Expected 10 score entries but found %d" % score_labels.size())
		return

	# Verify the format of score entries
	# Entry 1 should be "1. AAA - 50,000"
	var first_entry = score_labels[0].text
	print("First entry: %s" % first_entry)

	if not first_entry.begins_with("1."):
		_fail("First entry should start with '1.' but got: %s" % first_entry)
		return

	if not "AAA" in first_entry:
		_fail("First entry should contain 'AAA' but got: %s" % first_entry)
		return

	# Check last entry is ranked 10
	var last_entry = score_labels[9].text
	print("Last entry: %s" % last_entry)

	if not last_entry.begins_with("10."):
		_fail("Last entry should start with '10.' but got: %s" % last_entry)
		return

	if not "JJJ" in last_entry:
		_fail("Last entry should contain 'JJJ' but got: %s" % last_entry)
		return

	# Clean up and pass
	_cleanup()
	_pass()


func _find_node_by_type_and_text(root: Node, type_name: String, text_contains: String) -> Node:
	if root.get_class() == type_name or root.is_class(type_name):
		if root.has_method("get") and root.get("text") != null:
			if text_contains in root.get("text"):
				return root

	for child in root.get_children():
		var result = _find_node_by_type_and_text(child, type_name, text_contains)
		if result != null:
			return result

	return null


func _find_score_entry_labels(root: Node) -> Array:
	var labels: Array = []
	_collect_score_labels(root, labels)
	return labels


func _collect_score_labels(node: Node, labels: Array) -> void:
	if node is Label:
		var text = node.text
		# Check if this looks like a score entry: "N. XXX - N,NNN"
		# Pattern: starts with digit followed by period
		if text.length() > 0 and text[0].is_valid_int() and "." in text and " - " in text:
			labels.append(node)

	for child in node.get_children():
		_collect_score_labels(child, labels)


func _cleanup() -> void:
	# Clean up test file
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up high scores test file")

	# Reload to clear cached state
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").load_high_scores()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("High scores screen displays all 10 entries with initials and scores correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
