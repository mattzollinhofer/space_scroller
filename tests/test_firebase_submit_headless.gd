extends Node2D
## Test: submit_score must not write to the live leaderboard during headless
## (automated test) runs, so running the test suite never pollutes the shared
## online board with fixture scores.

func _ready() -> void:
	print("=== Test: Firebase submit disabled on headless runs ===")

	if not has_node("/root/FirebaseService"):
		_fail("FirebaseService autoload not found")
		return

	var firebase_service = get_node("/root/FirebaseService")

	# Sanity: this test runs headless, the environment the guard targets
	if DisplayServer.get_name() != "headless":
		_fail("Expected headless display server, got '%s'" % DisplayServer.get_name())
		return

	# The submit request node must start idle
	if firebase_service._submit_http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_fail("Submit request node was not idle at start")
		return

	# Submitting a score headless must NOT start a network request
	firebase_service.submit_score(12345, "GRD")

	if firebase_service._submit_http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_fail("submit_score started a network request during a headless run")
		return

	print("  - submit_score fired no request while headless: OK")
	_pass()


func _pass() -> void:
	print("=== TEST PASSED ===")
	await get_tree().create_timer(0.3).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit(1)
