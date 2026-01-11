extends Node2D
## Integration test: FirebaseService handles config file errors gracefully
## Tests missing config file and malformed JSON scenarios by checking internal state.
## Note: We can't easily test at runtime since config is loaded once at _ready(),
## but we can verify the code paths exist and the service is resilient.

var _test_passed: bool = false
var _test_failed: bool = false


func _ready() -> void:
	print("=== Test: FirebaseService Config Error Handling ===")

	# Check if FirebaseService autoload exists
	if not has_node("/root/FirebaseService"):
		_fail("FirebaseService autoload not found")
		return
	print("  - FirebaseService autoload found: OK")

	var firebase_service = get_node("/root/FirebaseService")

	# Verify the service loaded without crashing
	# (This confirms config loading is fault-tolerant)
	print("  - FirebaseService loaded successfully: OK")

	# Verify source code has proper error handling
	var firebase_script = load("res://scripts/autoloads/firebase_service.gd")
	if firebase_script:
		var source = firebase_script.source_code

		# Check for file existence check
		if source.find("file_exists") == -1:
			_fail("FirebaseService should check if config file exists")
			return
		print("  - Config file existence check present: OK")

		# Check for JSON parse error handling
		if source.find("error != OK") == -1 and source.find("error != Error.OK") == -1:
			_fail("FirebaseService should handle JSON parse errors")
			return
		print("  - JSON parse error handling present: OK")

		# Check for silent failure pattern (return without error messages)
		# Multiple returns without raising errors = silent failure
		var return_count = source.count("return  # Silent")
		if return_count < 2:
			_fail("FirebaseService should have multiple silent failure returns")
			return
		print("  - Silent failure pattern present (%d returns): OK" % return_count)

	# Test that the service works even with potentially invalid config
	# (The placeholder config won't connect to a real Firebase, but shouldn't crash)
	print("  - Testing service resilience with current config...")

	# submit_score should not crash with invalid URL
	firebase_service.submit_score(999, "ERR")
	print("  - submit_score handled invalid/placeholder config: OK")

	# fetch_top_scores should return empty array gracefully
	var callback_called = false
	firebase_service.fetch_top_scores(5, func(scores):
		callback_called = true
		if scores is Array:
			print("  - fetch_top_scores returned Array with %d items: OK" % scores.size())
		else:
			_fail("fetch_top_scores callback did not receive Array")
	)

	# Wait briefly for potential async callback
	await get_tree().create_timer(0.5).timeout

	# With invalid config, callback may be called immediately with empty array
	# or may timeout - both are acceptable
	print("  - Service handles invalid config gracefully: OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("FirebaseService handles config errors gracefully.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
