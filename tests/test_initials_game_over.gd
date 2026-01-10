extends Node2D
## Integration test: Full game over flow with initials entry
## Tests that when score qualifies for top 10:
## - Initials entry UI appears on game over screen
## - Player can enter initials
## - Score is saved with initials
## - High score label shows initials

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _game_over_screen: CanvasLayer = null
var _initials_entry: Control = null

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
const TEST_SCORE: int = 15000


func _ready() -> void:
	print("=== Test: Game Over Screen with Initials Entry ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

	# Get ScoreManager and set up test score
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")
	score_manager.load_high_scores()
	score_manager.reset_score()
	score_manager.add_points(TEST_SCORE)
	print("Set test score to: %s" % score_manager.get_score())

	# Load game over screen
	var scene = load("res://scenes/ui/game_over_screen.tscn")
	if scene == null:
		_fail("Could not load game_over_screen.tscn")
		return

	_game_over_screen = scene.instantiate()
	add_child(_game_over_screen)

	# Show game over screen
	_game_over_screen.show_game_over()

	# Wait a frame for UI to set up
	await get_tree().process_frame

	# Check if initials entry is shown (should be since score qualifies for top 10)
	_initials_entry = _game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/InitialsEntry")
	if _initials_entry == null:
		# Try alternate path
		_initials_entry = _find_initials_entry(_game_over_screen)

	if _initials_entry == null:
		_fail("InitialsEntry not found in game_over_screen")
		return

	if not _initials_entry.visible:
		_fail("InitialsEntry should be visible when score qualifies for top 10")
		return

	print("InitialsEntry found and visible")

	# Enter initials "XYZ"
	if _initials_entry.has_method("show_entry"):
		_initials_entry.show_entry()

	await get_tree().process_frame

	# Change to X (23 letters up from A)
	for i in range(23):
		_simulate_key_press(KEY_UP)
		await get_tree().process_frame

	# Move to second slot and change to Y (24 letters up)
	_simulate_key_press(KEY_RIGHT)
	await get_tree().process_frame

	for i in range(24):
		_simulate_key_press(KEY_UP)
		await get_tree().process_frame

	# Move to third slot and change to Z (25 letters up)
	_simulate_key_press(KEY_RIGHT)
	await get_tree().process_frame

	for i in range(25):
		_simulate_key_press(KEY_UP)
		await get_tree().process_frame

	# Verify initials before confirm
	var initials = _initials_entry.get_initials()
	print("Entered initials: '%s'" % initials)

	if initials != "XYZ":
		_fail("Expected initials 'XYZ', got '%s'" % initials)
		return

	# Press Enter to confirm
	_simulate_key_press(KEY_ENTER)
	await get_tree().process_frame
	await get_tree().process_frame

	# Wait for save to complete
	await get_tree().create_timer(0.2).timeout

	# Verify score was saved with initials
	var config = ConfigFile.new()
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		_fail("High scores file not created")
		return

	config.load(HIGH_SCORE_PATH)
	var saved_initials = config.get_value("high_scores", "initials_0", "")
	var saved_score = config.get_value("high_scores", "score_0", 0)

	print("Saved: score=%s, initials='%s'" % [saved_score, saved_initials])

	if saved_score != TEST_SCORE:
		_fail("Score not saved correctly. Expected %s, got %s" % [TEST_SCORE, saved_score])
		return

	if saved_initials != "XYZ":
		_fail("Initials not saved correctly. Expected 'XYZ', got '%s'" % saved_initials)
		return

	# Check high score label shows initials
	var high_score_label = _game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/HighScoreLabel")
	if high_score_label:
		print("High score label text: '%s'" % high_score_label.text)
		if "XYZ" not in high_score_label.text:
			_fail("High score label should contain 'XYZ', got: '%s'" % high_score_label.text)
			return

	_cleanup_high_scores_file()
	_pass()


func _find_initials_entry(node: Node) -> Control:
	for child in node.get_children():
		if child.name == "InitialsEntry":
			return child
		var found = _find_initials_entry(child)
		if found:
			return found
	return null


func _simulate_key_press(key: int) -> void:
	var event = InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)

	var release = InputEventKey.new()
	release.keycode = key
	release.pressed = false
	Input.parse_input_event(release)


func _cleanup_high_scores_file() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up high scores test file")


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
	print("Game over screen shows initials entry and saves correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
