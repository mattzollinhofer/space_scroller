extends Node2D
## Integration test: High scores screen shows correct data after multiple sessions
## Tests that initials and scores persist correctly across multiple save/load cycles,
## simulating the experience of playing multiple sessions.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0
var _step: int = 0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"


func _ready() -> void:
	print("=== Test: High Scores Persistence Across Sessions ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()
	_step = 1


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_cleanup_high_scores_file()
		_fail("Test timed out at step %d" % _step)
		return

	match _step:
		1:
			_simulate_session_1()
		2:
			_simulate_session_2()
		3:
			_simulate_session_3()
		4:
			_verify_final_state()


func _simulate_session_1() -> void:
	_step = -1  # Prevent re-entry
	print("--- Session 1: First player achieves high score ---")

	var score_manager = get_node("/root/ScoreManager")
	score_manager.load_high_scores()

	# Player 1 gets 10,000 with initials "AAA"
	score_manager.reset_score()
	score_manager.add_points(10000)
	score_manager.save_high_score("ABC")
	print("Session 1: Saved score 10,000 with initials 'ABC'")

	# Simulate closing and reopening the game
	_reload_score_manager()

	# Verify it persisted
	var scores = score_manager.get_high_scores()
	if scores.size() != 1:
		_fail("Session 1: Expected 1 score, got %d" % scores.size())
		return

	if scores[0]["initials"] != "ABC":
		_fail("Session 1: Expected initials 'ABC', got '%s'" % scores[0]["initials"])
		return

	print("Session 1: Verified score persisted")
	_step = 2


func _simulate_session_2() -> void:
	_step = -1
	print("--- Session 2: Second player beats high score ---")

	var score_manager = get_node("/root/ScoreManager")

	# Player 2 gets 15,000 with initials "XYZ"
	score_manager.reset_score()
	score_manager.add_points(15000)
	score_manager.save_high_score("XYZ")
	print("Session 2: Saved score 15,000 with initials 'XYZ'")

	# Simulate closing and reopening the game
	_reload_score_manager()

	# Verify both scores persisted in correct order
	var scores = score_manager.get_high_scores()
	if scores.size() != 2:
		_fail("Session 2: Expected 2 scores, got %d" % scores.size())
		return

	# First should be XYZ with 15,000
	if scores[0]["initials"] != "XYZ" or scores[0]["score"] != 15000:
		_fail("Session 2: First entry should be XYZ-15000, got %s-%d" % [scores[0]["initials"], scores[0]["score"]])
		return

	# Second should be ABC with 10,000
	if scores[1]["initials"] != "ABC" or scores[1]["score"] != 10000:
		_fail("Session 2: Second entry should be ABC-10000, got %s-%d" % [scores[1]["initials"], scores[1]["score"]])
		return

	print("Session 2: Verified both scores in correct order")
	_step = 3


func _simulate_session_3() -> void:
	_step = -1
	print("--- Session 3: Third player gets middle score ---")

	var score_manager = get_node("/root/ScoreManager")

	# Player 3 gets 12,000 with initials "MID"
	score_manager.reset_score()
	score_manager.add_points(12000)
	score_manager.save_high_score("MID")
	print("Session 3: Saved score 12,000 with initials 'MID'")

	# Simulate closing and reopening the game
	_reload_score_manager()

	# Verify all three scores in correct order
	var scores = score_manager.get_high_scores()
	if scores.size() != 3:
		_fail("Session 3: Expected 3 scores, got %d" % scores.size())
		return

	var expected = [
		{"initials": "XYZ", "score": 15000},
		{"initials": "MID", "score": 12000},
		{"initials": "ABC", "score": 10000}
	]

	for i in range(3):
		if scores[i]["initials"] != expected[i]["initials"] or scores[i]["score"] != expected[i]["score"]:
			_fail("Session 3: Entry %d should be %s-%d, got %s-%d" % [
				i + 1,
				expected[i]["initials"], expected[i]["score"],
				scores[i]["initials"], scores[i]["score"]
			])
			return

	print("Session 3: All three scores in correct order")
	_step = 4


func _verify_final_state() -> void:
	_step = -1
	print("--- Final Verification: High Scores Screen ---")

	# Load the high scores screen
	if not ResourceLoader.exists("res://scenes/ui/high_scores_screen.tscn"):
		_fail("high_scores_screen.tscn does not exist")
		return

	var scene = load("res://scenes/ui/high_scores_screen.tscn")
	var high_scores_screen = scene.instantiate()
	add_child(high_scores_screen)

	# Wait for scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame

	# Find score labels
	var score_labels = _find_score_entry_labels(high_scores_screen)
	print("Found %d score entry labels" % score_labels.size())

	if score_labels.size() < 3:
		_fail("Expected at least 3 score entries on screen")
		return

	# Verify first entry: XYZ - 15,000
	var entry1 = score_labels[0].text
	print("Entry 1: %s" % entry1)
	if not ("XYZ" in entry1 and "15,000" in entry1):
		_fail("Entry 1 should show 'XYZ' and '15,000', got: %s" % entry1)
		return

	# Verify second entry: MID - 12,000
	var entry2 = score_labels[1].text
	print("Entry 2: %s" % entry2)
	if not ("MID" in entry2 and "12,000" in entry2):
		_fail("Entry 2 should show 'MID' and '12,000', got: %s" % entry2)
		return

	# Verify third entry: ABC - 10,000
	var entry3 = score_labels[2].text
	print("Entry 3: %s" % entry3)
	if not ("ABC" in entry3 and "10,000" in entry3):
		_fail("Entry 3 should show 'ABC' and '10,000', got: %s" % entry3)
		return

	print("All entries display correctly on high scores screen")

	# Clean up
	_cleanup_high_scores_file()
	_pass()


func _reload_score_manager() -> void:
	# Simulate closing and reopening the game by reloading high scores
	var score_manager = get_node("/root/ScoreManager")
	score_manager.load_high_scores()


func _find_score_entry_labels(root: Node) -> Array:
	var labels: Array = []
	_collect_score_labels(root, labels)
	return labels


func _collect_score_labels(node: Node, labels: Array) -> void:
	if node is Label:
		var text = node.text
		if text.length() > 0 and text[0].is_valid_int() and "." in text and " - " in text:
			labels.append(node)

	for child in node.get_children():
		_collect_score_labels(child, labels)


func _cleanup_high_scores_file() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up high scores test file")

	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").load_high_scores()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("High scores persist correctly across multiple sessions.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
