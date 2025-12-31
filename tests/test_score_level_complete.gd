extends Node2D
## Integration test: Score increases when level is completed
## Verifies that completing a level awards 5,000 bonus points.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 10.0
var _timer: float = 0.0

var _main: Node = null
var _level_manager: Node = null
var _scroll_controller: Node = null
var _score_before_completion: int = 0
var _level_completed_signaled: bool = false


func _ready() -> void:
	print("=== Test: Score Increases When Level Completed ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	_main = main_scene.instantiate()
	add_child(_main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find the level manager
	_level_manager = _main.get_node_or_null("LevelManager")
	if not _level_manager:
		_fail("LevelManager node not found in main scene")
		return

	# Find the scroll controller (ParallaxBackground)
	_scroll_controller = _main.get_node_or_null("ParallaxBackground")
	if not _scroll_controller:
		_fail("ParallaxBackground (scroll controller) not found in main scene")
		return

	# Disable enemy spawning to have a clean test
	var enemy_spawner = _main.get_node_or_null("EnemySpawner")
	if enemy_spawner:
		enemy_spawner.set_continuous_spawning(false)
		enemy_spawner.clear_all()

	# Wait another frame for things to settle
	await get_tree().process_frame

	# Run the test
	await _run_level_complete_test()


func _run_level_complete_test() -> void:
	# Reset score to ensure clean state
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").reset_score()

	# Give some initial points to verify the bonus adds to existing score
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").add_points(1000)

	_score_before_completion = _get_current_score()
	print("Score before level completion: %d" % _score_before_completion)

	# Connect to level_completed signal to know when it fires
	if _level_manager.has_signal("level_completed"):
		_level_manager.level_completed.connect(_on_level_completed)

	# Simulate reaching the end of the level by setting scroll offset
	# The level total distance is typically 9000, so setting scroll_offset.x to -9000
	# should trigger level completion (100% progress)
	var total_distance = _level_manager.get_total_distance()
	print("Total level distance: %d" % total_distance)

	# Set scroll to end of level (scroll_offset.x is negative)
	_scroll_controller.scroll_offset.x = -total_distance

	# Wait for level manager to process and detect completion
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	# Give extra time for signal to propagate
	await get_tree().create_timer(0.2).timeout

	# Check if level completion was signaled
	if not _level_completed_signaled:
		_fail("Level completed signal was not emitted")
		return

	# Check score increased by 5,000 points
	var new_score = _get_current_score()
	print("Score after level completion: %d" % new_score)

	var expected_score = _score_before_completion + 5000
	if new_score != expected_score:
		_fail("Expected score %d after level completion, got %d" % [expected_score, new_score])
		return

	print("Level completion awarded 5,000 bonus points correctly!")
	_pass()


func _on_level_completed() -> void:
	_level_completed_signaled = true
	print("Level completed signal received!")


func _get_current_score() -> int:
	# Try to get score from ScoreManager autoload first
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("get_score"):
			return score_manager.get_score()
	return 0


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
	print("Score increases correctly when level is completed.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
