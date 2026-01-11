extends Node2D
## Integration test: Initials entry on level complete screen
## Tests that when score qualifies for top 10 on level complete:
## - Initials entry UI appears
## - Player can enter initials
## - Score is saved with initials
## - High score label shows initials
## - Buttons appear after confirming initials

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _level_complete_screen: CanvasLayer = null
var _initials_entry: Control = null

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
const TEST_SCORE: int = 15000


func _ready() -> void:
	print("=== Test: Level Complete Screen with Initials Entry ===")

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

	# Load level complete screen
	var scene = load("res://scenes/ui/level_complete_screen.tscn")
	if scene == null:
		_fail("Could not load level_complete_screen.tscn")
		return

	_level_complete_screen = scene.instantiate()
	add_child(_level_complete_screen)

	# Set to final level (6) - initials only show on game complete
	_level_complete_screen.set_current_level(6)

	# Show level complete screen
	_level_complete_screen.show_level_complete()

	# Wait a frame for UI to set up
	await get_tree().process_frame

	# Check if initials entry is shown (should be since score qualifies for top 10)
	_initials_entry = _level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/InitialsEntry")
	if _initials_entry == null:
		# Try alternate path
		_initials_entry = _find_initials_entry(_level_complete_screen)

	if _initials_entry == null:
		_fail("InitialsEntry not found in level_complete_screen")
		return

	if not _initials_entry.visible:
		_fail("InitialsEntry should be visible when score qualifies for top 10")
		return

	print("InitialsEntry found and visible")

	# Check that buttons are hidden during initials entry
	var next_level_button = _level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/NextLevelButton")
	var main_menu_button = _level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/MainMenuButton")

	if next_level_button and next_level_button.visible:
		_fail("NextLevelButton should be hidden during initials entry")
		return

	if main_menu_button and main_menu_button.visible:
		_fail("MainMenuButton should be hidden during initials entry")
		return

	print("Buttons correctly hidden during initials entry")

	# Enter initials "ABC"
	if _initials_entry.has_method("show_entry"):
		_initials_entry.show_entry()

	await get_tree().process_frame

	# Keep slot 0 as A (already default)
	# Move to second slot and change to B (1 letter up)
	_simulate_key_press(KEY_RIGHT)
	await get_tree().process_frame

	_simulate_key_press(KEY_UP)
	await get_tree().process_frame

	# Move to third slot and change to C (2 letters up)
	_simulate_key_press(KEY_RIGHT)
	await get_tree().process_frame

	_simulate_key_press(KEY_UP)
	await get_tree().process_frame
	_simulate_key_press(KEY_UP)
	await get_tree().process_frame

	# Verify initials before confirm
	var initials = _initials_entry.get_initials()
	print("Entered initials: '%s'" % initials)

	if initials != "ABC":
		_fail("Expected initials 'ABC', got '%s'" % initials)
		return

	# Press Enter to confirm
	_simulate_key_press(KEY_ENTER)
	await get_tree().process_frame
	await get_tree().process_frame

	# Wait for save to complete
	await get_tree().create_timer(0.2).timeout

	# Verify initials entry is now hidden
	if _initials_entry.visible:
		_fail("InitialsEntry should be hidden after confirming")
		return

	print("InitialsEntry hidden after confirmation")

	# Verify buttons are now visible
	# Re-get buttons in case visibility changed
	next_level_button = _level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/NextLevelButton")
	main_menu_button = _level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/MainMenuButton")

	# At least one button should be visible (depends on current level)
	var any_button_visible = (next_level_button and next_level_button.visible) or (main_menu_button and main_menu_button.visible)
	if not any_button_visible:
		_fail("At least one button (NextLevel or MainMenu) should be visible after confirming initials")
		return

	print("Buttons visible after confirmation")

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

	if saved_initials != "ABC":
		_fail("Initials not saved correctly. Expected 'ABC', got '%s'" % saved_initials)
		return

	# Check high score label shows initials
	var high_score_label = _level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/HighScoreLabel")
	if high_score_label:
		print("High score label text: '%s'" % high_score_label.text)
		if "ABC" not in high_score_label.text:
			_fail("High score label should contain 'ABC', got: '%s'" % high_score_label.text)
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
	print("Level complete screen shows initials entry and saves correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
