extends Node2D
## Integration test: High scores screen shows placeholder for empty slots
## Tests that when there are fewer than 10 high scores, empty slots show "N. --- - 0"

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"


func _ready() -> void:
	print("=== Test: High Scores Empty Slots ===")

	# Clean up any existing high scores file
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up existing high scores file")

	# Get ScoreManager and reload to clear cached state
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")
	score_manager.load_high_scores()

	# Add only 3 test scores (leaving 7 empty slots)
	var test_scores = [
		{"score": 30000, "initials": "TOP"},
		{"score": 20000, "initials": "MID"},
		{"score": 10000, "initials": "LOW"},
	]

	for entry in test_scores:
		score_manager.reset_score()
		score_manager.add_points(entry["score"])
		score_manager.save_high_score(entry["initials"])

	print("Set up 3 test scores")

	# Load high scores screen
	await get_tree().process_frame
	_load_high_scores_screen()


func _load_high_scores_screen() -> void:
	print("Loading high scores screen...")

	if not ResourceLoader.exists("res://scenes/ui/high_scores_screen.tscn"):
		_fail("high_scores_screen.tscn does not exist")
		return

	var scene = load("res://scenes/ui/high_scores_screen.tscn")
	var screen = scene.instantiate()
	add_child(screen)

	await get_tree().process_frame
	await get_tree().process_frame

	_verify_empty_slots(screen)


func _verify_empty_slots(screen: Node) -> void:
	print("Verifying empty slot placeholders...")

	# Find all score entry labels
	var score_labels = _find_score_entry_labels(screen)
	print("Found %d score entry labels" % score_labels.size())

	if score_labels.size() != 10:
		_fail("Expected 10 score entries but found %d" % score_labels.size())
		return

	# Verify first 3 entries have real data
	var first_entry = score_labels[0].text
	print("Entry 1: %s" % first_entry)
	if not "TOP" in first_entry:
		_fail("First entry should contain 'TOP' but got: %s" % first_entry)
		return

	var third_entry = score_labels[2].text
	print("Entry 3: %s" % third_entry)
	if not "LOW" in third_entry:
		_fail("Third entry should contain 'LOW' but got: %s" % third_entry)
		return

	# Verify entries 4-10 are empty placeholders
	for i in range(3, 10):
		var entry = score_labels[i].text
		print("Entry %d: %s" % [i + 1, entry])

		# Check for placeholder format: "N. --- - 0"
		if not "---" in entry:
			_fail("Empty slot %d should contain '---' but got: %s" % [i + 1, entry])
			return

		if not " - 0" in entry:
			_fail("Empty slot %d should end with ' - 0' but got: %s" % [i + 1, entry])
			return

	print("All empty slots have correct placeholder format")

	# Clean up
	_cleanup()
	_pass()


func _find_score_entry_labels(root: Node) -> Array:
	var labels: Array = []
	_collect_score_labels(root, labels)
	return labels


func _collect_score_labels(node: Node, labels: Array) -> void:
	if node is Label:
		var text = node.text
		# Check if this looks like a score entry: starts with digit followed by period
		if text.length() > 0 and text[0].is_valid_int() and "." in text:
			labels.append(node)

	for child in node.get_children():
		_collect_score_labels(child, labels)


func _cleanup() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up high scores test file")

	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").load_high_scores()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_cleanup()
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Empty slots correctly display placeholder format.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
