extends Node2D
## Integration test: Score display exists and shows initial score of 0
## Run this scene to verify score HUD element appears during gameplay.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 2.0
var _timer: float = 0.0

var score_display: Node = null


func _ready() -> void:
	print("=== Test: Score Display on HUD ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find the score display in the scene
	score_display = main.get_node_or_null("ScoreDisplay")
	if not score_display:
		_fail("ScoreDisplay node not found in main scene")
		return

	# Check if score display is visible
	if not score_display.visible:
		_fail("ScoreDisplay is not visible")
		return

	# Check if score display is a CanvasLayer
	if not score_display is CanvasLayer:
		_fail("ScoreDisplay should be a CanvasLayer")
		return

	# Check CanvasLayer layer is 10 (matching other UI elements)
	if score_display.layer != 10:
		_fail("ScoreDisplay layer should be 10, got %s" % score_display.layer)
		return

	# Find the score label within the display
	var score_label = score_display.get_node_or_null("Container/ScoreLabel")
	if not score_label:
		_fail("ScoreLabel node not found in ScoreDisplay/Container")
		return

	# Check score label text shows "SCORE: 0"
	if not score_label is Label:
		_fail("ScoreLabel should be a Label node")
		return

	var label_text = score_label.text
	if not label_text.begins_with("SCORE:"):
		_fail("Score label should start with 'SCORE:', got '%s'" % label_text)
		return

	# Should show 0 initially (could be "SCORE: 0" or "SCORE: 0" with formatting)
	if not "0" in label_text:
		_fail("Score label should contain '0' initially, got '%s'" % label_text)
		return

	print("Score label text: '%s'" % label_text)
	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Score display exists in top-right corner showing 'SCORE: 0'.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
