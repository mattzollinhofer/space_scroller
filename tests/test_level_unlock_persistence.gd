extends Node2D
## Integration test: ScoreManager persists level unlock state to ConfigFile
## Verifies that unlock_level() and is_level_unlocked() work correctly.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level Unlock Persistence ===")

	# Check ScoreManager autoload exists
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")
	print("ScoreManager found")

	# Verify is_level_unlocked method exists
	if not score_manager.has_method("is_level_unlocked"):
		_fail("ScoreManager missing is_level_unlocked method")
		return

	print("is_level_unlocked method exists")

	# Verify unlock_level method exists
	if not score_manager.has_method("unlock_level"):
		_fail("ScoreManager missing unlock_level method")
		return

	print("unlock_level method exists")

	# Level 1 should always be unlocked
	if not score_manager.is_level_unlocked(1):
		_fail("Level 1 should always be unlocked")
		return

	print("Level 1 is unlocked by default (correct)")

	# Level 2 should initially be locked (reset first)
	if score_manager.has_method("reset_level_unlocks"):
		score_manager.reset_level_unlocks()

	if score_manager.is_level_unlocked(2):
		_fail("Level 2 should be locked initially after reset")
		return

	print("Level 2 is locked initially (correct)")

	# Unlock Level 2
	score_manager.unlock_level(2)

	if not score_manager.is_level_unlocked(2):
		_fail("Level 2 should be unlocked after calling unlock_level(2)")
		return

	print("Level 2 is unlocked after unlock_level(2) (correct)")

	# Level 3 should still be locked
	if score_manager.is_level_unlocked(3):
		_fail("Level 3 should still be locked")
		return

	print("Level 3 is still locked (correct)")

	# Verify persistence by reloading
	if score_manager.has_method("load_high_scores"):
		score_manager.load_high_scores()

	if not score_manager.is_level_unlocked(2):
		_fail("Level 2 should still be unlocked after reload")
		return

	print("Level 2 persisted after reload (correct)")

	# Clean up - reset unlocks for other tests
	if score_manager.has_method("reset_level_unlocks"):
		score_manager.reset_level_unlocks()

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level unlock persistence works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
