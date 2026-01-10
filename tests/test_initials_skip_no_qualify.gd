extends Node2D
## Integration test: Score that doesn't qualify for top 10 skips initials entry entirely
## Tests that when a player's score is too low to make the top 10, the initials
## entry UI never appears and they go straight to the game over screen.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
var game_over_screen: Node = null


func _ready() -> void:
	print("=== Test: Score Not Qualifying Skips Initials Entry ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

	# Fill up the top 10 with high scores
	_fill_top_10_with_high_scores()

	# Load the main scene and test
	_test_low_score_skips_initials()


func _fill_top_10_with_high_scores() -> void:
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")
	score_manager.load_high_scores()

	# Add 10 high scores (all high values)
	var scores = [50000, 45000, 40000, 35000, 30000, 25000, 20000, 15000, 10000, 8000]
	for i in range(scores.size()):
		score_manager.reset_score()
		score_manager.add_points(scores[i])
		score_manager.save_high_score("P%02d" % (i + 1))

	print("Filled top 10 with scores from 50,000 to 8,000")

	# Verify we have 10 scores
	var high_scores = score_manager.get_high_scores()
	print("High scores count: %d" % high_scores.size())
	print("Lowest qualifying score: %d" % high_scores[high_scores.size() - 1]["score"])


func _test_low_score_skips_initials() -> void:
	var score_manager = get_node("/root/ScoreManager")

	# Set a low score that won't qualify (5000 is less than 8000)
	score_manager.reset_score()
	score_manager.add_points(5000)
	print("Set current score to: %d (should NOT qualify for top 10)" % score_manager.get_score())

	# Verify it doesn't qualify
	if score_manager.qualifies_for_top_10():
		_fail("Score of 5000 should NOT qualify for top 10 but qualifies_for_top_10() returned true")
		return

	print("qualifies_for_top_10() correctly returns false")

	# Load main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Wait for scene to initialize
	await get_tree().process_frame

	# Find game over screen
	game_over_screen = main.get_node_or_null("GameOverScreen")
	if not game_over_screen:
		_fail("GameOverScreen node not found")
		return

	# Show game over screen
	print("Showing game over screen...")
	game_over_screen.show_game_over()

	# Wait for display to update
	await get_tree().process_frame
	await get_tree().process_frame

	# Check that initials entry is NOT visible
	var initials_entry = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/InitialsEntry")
	if initials_entry == null:
		print("InitialsEntry node not found (which is fine)")
	elif initials_entry.visible:
		_fail("InitialsEntry should NOT be visible when score doesn't qualify for top 10")
		return
	else:
		print("InitialsEntry correctly hidden (score doesn't qualify)")

	# Check that main menu button IS visible immediately
	var main_menu_button = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/MainMenuButton")
	if not main_menu_button:
		_fail("MainMenuButton not found")
		return

	if not main_menu_button.visible:
		_fail("MainMenuButton should be visible immediately when score doesn't qualify")
		return

	print("MainMenuButton correctly visible immediately")

	# Check that NEW HIGH SCORE indicator is NOT visible
	var new_high_score_label = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/NewHighScoreLabel")
	if new_high_score_label and new_high_score_label.visible:
		_fail("NEW HIGH SCORE indicator should NOT be visible for non-qualifying score")
		return

	print("NEW HIGH SCORE indicator correctly hidden")

	# Verify score was NOT added to high scores list (still only 10 entries)
	var high_scores = score_manager.get_high_scores()
	if high_scores.size() != 10:
		_fail("High scores list should still have exactly 10 entries, got %d" % high_scores.size())
		return

	# Verify the lowest score is still 8000 (our 5000 wasn't added)
	var lowest_score = high_scores[high_scores.size() - 1]["score"]
	if lowest_score != 8000:
		_fail("Lowest high score should still be 8000, got %d" % lowest_score)
		return

	print("Score list unchanged (non-qualifying score not added)")

	# Clean up
	_cleanup_high_scores_file()
	_pass()


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
	print("Score not qualifying for top 10 correctly skips initials entry.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
