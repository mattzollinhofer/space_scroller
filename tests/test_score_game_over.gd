extends Node2D
## Integration test: Score is displayed on the Game Over screen
## Run this scene to verify the final score appears when game over is shown.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var game_over_screen: Node = null
var _expected_score: int = 1500


func _ready() -> void:
	print("=== Test: Score on Game Over Screen ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find game over screen
	game_over_screen = main.get_node_or_null("GameOverScreen")
	if not game_over_screen:
		_fail("GameOverScreen node not found")
		return

	# Reset score and add test points
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		score_manager.reset_score()
		score_manager.add_points(_expected_score)
		print("Set test score to: %s" % score_manager.get_score())
	else:
		_fail("ScoreManager autoload not found")
		return

	# Directly show game over screen (simulates what happens on player death)
	print("Showing game over screen...")
	game_over_screen.show_game_over()

	# Wait a frame for display to update
	await get_tree().process_frame

	_check_game_over_score()


func _check_game_over_score() -> void:
	if _test_passed or _test_failed:
		return

	# Check game over screen is visible
	if not game_over_screen.visible:
		_fail("Game over screen not visible")
		return

	print("Game over screen is visible")

	# Find the score label in game over screen
	var score_label = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/ScoreLabel")
	if not score_label:
		_fail("ScoreLabel not found in game over screen (expected at CenterContainer/VBoxContainer/ScoreLabel)")
		return

	# Check score label is a Label
	if not score_label is Label:
		_fail("ScoreLabel should be a Label node")
		return

	# Check score label text contains "SCORE:"
	var label_text = score_label.text
	print("Score label text: '%s'" % label_text)

	if not label_text.begins_with("SCORE:"):
		_fail("Score label should start with 'SCORE:', got '%s'" % label_text)
		return

	# Check score label contains the expected score (formatted with commas)
	# 1500 should be "1,500"
	var expected_formatted = "1,500"
	if not expected_formatted in label_text:
		_fail("Score label should contain '%s', got '%s'" % [expected_formatted, label_text])
		return

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Game over screen shows score correctly formatted.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
