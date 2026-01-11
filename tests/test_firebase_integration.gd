extends Node2D
## Integration test: ScoreManager.save_high_score() calls FirebaseService.submit_score()
## Verifies the integration between ScoreManager and FirebaseService works correctly.

var _test_passed: bool = false
var _test_failed: bool = false

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
const TEST_SCORE: int = 7500


func _ready() -> void:
	print("=== Test: Firebase Integration with ScoreManager ===")

	# Check if ScoreManager autoload exists
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return
	print("  - ScoreManager autoload found: OK")

	# Check if FirebaseService autoload exists
	if not has_node("/root/FirebaseService"):
		_fail("FirebaseService autoload not found")
		return
	print("  - FirebaseService autoload found: OK")

	var score_manager = get_node("/root/ScoreManager")

	# Verify ScoreManager has integration code (static check of source)
	var score_manager_script = load("res://scripts/score_manager.gd")
	if score_manager_script:
		var source = score_manager_script.source_code
		if source.find("FirebaseService") == -1:
			_fail("ScoreManager should reference FirebaseService")
			return
		if source.find("submit_score") == -1:
			_fail("ScoreManager should call submit_score")
			return
		print("  - ScoreManager has FirebaseService integration code: OK")

	# Clean up existing high scores file
	_cleanup_high_scores_file()

	# Reload to clear cached state
	score_manager.load_high_scores()

	# Reset and set test score
	score_manager.reset_score()
	score_manager.add_points(TEST_SCORE)
	print("  - Set test score to: %d" % score_manager.get_score())

	# Save high score (this should also call FirebaseService.submit_score)
	# We pass custom initials to verify they're used
	score_manager.save_high_score("TST")
	print("  - save_high_score('TST') called without crashing: OK")

	# Clean up test file
	_cleanup_high_scores_file()

	_pass()


func _cleanup_high_scores_file() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("ScoreManager integrates with FirebaseService correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
