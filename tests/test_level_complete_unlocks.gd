extends Node2D
## Integration test: Completing Level 1 unlocks Level 2
## Verifies that show_level_complete calls unlock_level for next level.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level Complete Unlocks Next Level ===")

	# Check ScoreManager autoload exists
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reset level unlocks
	if score_manager.has_method("reset_level_unlocks"):
		score_manager.reset_level_unlocks()

	# Verify Level 2 is locked initially
	if score_manager.is_level_unlocked(2):
		_fail("Level 2 should be locked initially")
		return

	print("Level 2 is locked initially (correct)")

	# Load level complete screen
	var screen_scene = load("res://scenes/ui/level_complete_screen.tscn")
	if not screen_scene:
		_fail("Could not load level complete screen scene")
		return

	var screen = screen_scene.instantiate()
	add_child(screen)

	# Set current level to 1 (simulating completing Level 1)
	if screen.has_method("set_current_level"):
		screen.set_current_level(1)
	elif "current_level" in screen:
		screen.current_level = 1

	# Show level complete screen (should unlock Level 2)
	if screen.has_method("show_level_complete"):
		screen.show_level_complete()
	else:
		_fail("Level complete screen missing show_level_complete method")
		return

	# Wait a frame for processing
	await get_tree().process_frame

	# Verify Level 2 is now unlocked
	if not score_manager.is_level_unlocked(2):
		_fail("Level 2 should be unlocked after completing Level 1")
		return

	print("Level 2 is unlocked after completing Level 1 (correct)")

	# Verify Level 3 is still locked
	if score_manager.is_level_unlocked(3):
		_fail("Level 3 should still be locked")
		return

	print("Level 3 is still locked (correct)")

	# Reset for other tests
	score_manager.reset_level_unlocks()

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Completing Level 1 correctly unlocks Level 2.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
