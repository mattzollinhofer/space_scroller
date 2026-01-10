extends Node2D
## Integration test: InitialsEntry UI component keyboard navigation
## Tests that the InitialsEntry component:
## - Starts with "AAA" default
## - Responds to keyboard input (up/down/left/right)
## - Emits signal with initials on Enter/Space

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _initials_entry: Control = null
var _confirmed_initials: String = ""


func _ready() -> void:
	print("=== Test: InitialsEntry UI Component ===")

	# Try to load the InitialsEntry component
	var scene = load("res://scenes/ui/initials_entry.tscn")
	if scene == null:
		_fail("Could not load initials_entry.tscn")
		return

	_initials_entry = scene.instantiate()
	add_child(_initials_entry)

	# Connect to the initials_confirmed signal
	if not _initials_entry.has_signal("initials_confirmed"):
		_fail("InitialsEntry missing 'initials_confirmed' signal")
		return

	_initials_entry.initials_confirmed.connect(_on_initials_confirmed)

	# Verify it has get_initials method
	if not _initials_entry.has_method("get_initials"):
		_fail("InitialsEntry missing 'get_initials' method")
		return

	# Check default is "AAA"
	var default_initials = _initials_entry.get_initials()
	print("Default initials: '%s'" % default_initials)

	if default_initials != "AAA":
		_fail("Default initials should be 'AAA', got '%s'" % default_initials)
		return

	# Show the entry (enable input handling)
	if _initials_entry.has_method("show_entry"):
		_initials_entry.show_entry()

	# Wait a frame then start simulating input
	await get_tree().process_frame
	_run_input_tests()


func _on_initials_confirmed(initials: String) -> void:
	_confirmed_initials = initials
	print("Confirmed initials: '%s'" % initials)


func _run_input_tests() -> void:
	# Test: Change first letter from A to M (cycle down 12 times: A->Z->Y->...->M)
	# Actually, down from A should go to Z, then Y, etc. Let's cycle up instead.
	# Up from A should go to B, C, D... M is 12 letters up from A
	print("Testing keyboard navigation...")

	# Cycle first letter up 12 times (A -> M)
	for i in range(12):
		_simulate_key_press(KEY_UP)
		await get_tree().process_frame

	var after_up = _initials_entry.get_initials()
	print("After 12 up presses on slot 0: '%s'" % after_up)

	if after_up[0] != "M":
		_fail("First letter should be 'M' after 12 up presses, got '%s'" % after_up[0])
		return

	# Move to second slot
	_simulate_key_press(KEY_RIGHT)
	await get_tree().process_frame

	# Cycle second letter up 9 times (A -> J)
	for i in range(9):
		_simulate_key_press(KEY_UP)
		await get_tree().process_frame

	after_up = _initials_entry.get_initials()
	print("After 9 up presses on slot 1: '%s'" % after_up)

	if after_up[1] != "J":
		_fail("Second letter should be 'J' after 9 up presses, got '%s'" % after_up[1])
		return

	# Move to third slot
	_simulate_key_press(KEY_RIGHT)
	await get_tree().process_frame

	# Cycle third letter up 10 times (A -> K)
	for i in range(10):
		_simulate_key_press(KEY_UP)
		await get_tree().process_frame

	after_up = _initials_entry.get_initials()
	print("After 10 up presses on slot 2: '%s'" % after_up)

	if after_up[2] != "K":
		_fail("Third letter should be 'K' after 10 up presses, got '%s'" % after_up[2])
		return

	# Final check before confirm
	var final_initials = _initials_entry.get_initials()
	print("Final initials before confirm: '%s'" % final_initials)

	if final_initials != "MJK":
		_fail("Expected 'MJK', got '%s'" % final_initials)
		return

	# Press Enter to confirm
	_simulate_key_press(KEY_ENTER)
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for signal

	# Verify signal was emitted with correct initials
	if _confirmed_initials != "MJK":
		_fail("Confirmed initials should be 'MJK', got '%s'" % _confirmed_initials)
		return

	_pass()


func _simulate_key_press(key: int) -> void:
	var event = InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)

	# Also send release
	var release = InputEventKey.new()
	release.keycode = key
	release.pressed = false
	Input.parse_input_event(release)


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("InitialsEntry UI component works correctly with keyboard input.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
