extends Node2D
## Integration test: FirebaseService autoload exists and has required methods
## Verifies FirebaseService is properly registered and has submit_score method.
## Tests that submit_score can be called without crashing.

var _test_passed: bool = false
var _test_failed: bool = false


func _ready() -> void:
	print("=== Test: FirebaseService Autoload ===")

	# Check if FirebaseService autoload exists
	if not has_node("/root/FirebaseService"):
		_fail("FirebaseService autoload not found")
		return
	print("  - FirebaseService autoload found: OK")

	var firebase_service = get_node("/root/FirebaseService")

	# Verify submit_score method exists
	if not firebase_service.has_method("submit_score"):
		_fail("FirebaseService does not have 'submit_score' method")
		return
	print("  - FirebaseService has submit_score method: OK")

	# Test that submit_score can be called without crashing
	# This tests with default initials
	firebase_service.submit_score(1000)
	print("  - submit_score(1000) called successfully: OK")

	# Test with custom initials
	firebase_service.submit_score(2000, "TST")
	print("  - submit_score(2000, 'TST') called successfully: OK")

	# Test with empty initials (should use default "AAA")
	firebase_service.submit_score(500, "")
	print("  - submit_score(500, '') called successfully: OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("FirebaseService autoload exists and submit_score works.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
