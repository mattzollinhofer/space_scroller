extends Node
## Test that resetting score does not affect level unlocks


func _ready() -> void:
	print("=== Test: Score Reset Preserves Level Unlocks ===")

	# Get ScoreManager
	if not has_node("/root/ScoreManager"):
		print("ERROR: ScoreManager not found")
		get_tree().quit(1)
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reset unlocks for clean test
	if score_manager.has_method("reset_level_unlocks"):
		score_manager.reset_level_unlocks()

	# Add some score
	score_manager.add_points(1000)
	if score_manager.get_score() != 1000:
		print("ERROR: Score should be 1000")
		get_tree().quit(1)
		return
	print("Score set to 1000 (correct)")

	# Unlock Level 2
	score_manager.unlock_level(2)
	if not score_manager.is_level_unlocked(2):
		print("ERROR: Level 2 should be unlocked")
		get_tree().quit(1)
		return
	print("Level 2 unlocked (correct)")

	# Reset score (simulating new game)
	score_manager.reset_score()
	if score_manager.get_score() != 0:
		print("ERROR: Score should be 0 after reset")
		get_tree().quit(1)
		return
	print("Score reset to 0 (correct)")

	# Verify Level 2 is still unlocked
	if not score_manager.is_level_unlocked(2):
		print("ERROR: Level 2 should still be unlocked after score reset")
		get_tree().quit(1)
		return
	print("Level 2 still unlocked after score reset (correct)")

	# Cleanup
	score_manager.reset_level_unlocks()

	print("")
	print("=== TEST PASSED ===")
	print("Score reset correctly preserves level unlocks.")
	get_tree().quit(0)
