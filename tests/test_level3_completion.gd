extends Node
## Test that completing Level 3 works correctly without errors
## (no Level 4 to unlock, but unlock_level(4) should not crash)


func _ready() -> void:
	print("=== Test: Level 3 Completion Edge Case ===")

	# Get ScoreManager
	if not has_node("/root/ScoreManager"):
		print("ERROR: ScoreManager not found")
		get_tree().quit(1)
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reset unlocks for clean test
	if score_manager.has_method("reset_level_unlocks"):
		score_manager.reset_level_unlocks()

	# Unlock levels 2 and 3 to simulate progress
	score_manager.unlock_level(2)
	score_manager.unlock_level(3)

	# Verify Level 3 is unlocked
	if not score_manager.is_level_unlocked(3):
		print("ERROR: Level 3 should be unlocked")
		get_tree().quit(1)
		return
	print("Level 3 is unlocked (correct)")

	# Now simulate completing Level 3 - this calls unlock_level(4)
	# which should NOT crash even though there's no Level 4
	print("Calling unlock_level(4) - should not crash...")
	score_manager.unlock_level(4)
	print("unlock_level(4) completed without error")

	# Check that Level 4 is marked as unlocked (even though it doesn't exist in UI)
	var level4_unlocked = score_manager.is_level_unlocked(4)
	print("Level 4 unlocked status: %s (stored, even if unused)" % level4_unlocked)

	# The key thing is that no crash occurred
	print("")
	print("=== TEST PASSED ===")
	print("Level 3 completion (unlock_level(4)) works without crashing.")

	# Cleanup
	score_manager.reset_level_unlocks()

	get_tree().quit(0)
