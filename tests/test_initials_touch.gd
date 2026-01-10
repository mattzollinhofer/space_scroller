extends Node2D
## Integration test: Touch-based initials entry saves correctly
## Tests that the InitialsEntry component:
## - Has up/down buttons for each letter slot
## - Tapping up/down cycles the letter in that slot
## - Tapping a slot makes it the active slot
## - OK button confirms and saves initials
## - Touch and keyboard input can be used interchangeably

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _initials_entry: Control = null
var _confirmed_initials: String = ""


func _ready() -> void:
	print("=== Test: InitialsEntry Touch Controls ===")

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

	# Show the entry (enable input handling)
	if _initials_entry.has_method("show_entry"):
		_initials_entry.show_entry()

	# Wait a frame then start tests
	await get_tree().process_frame
	await _run_touch_tests()


func _on_initials_confirmed(initials: String) -> void:
	_confirmed_initials = initials
	print("Confirmed initials: '%s'" % initials)


func _run_touch_tests() -> void:
	# Test 1: Verify touch buttons exist for each slot
	print("Testing touch button existence...")

	# Check for up buttons
	var up_button_0 = _initials_entry.find_child("UpButton0", true, false)
	var up_button_1 = _initials_entry.find_child("UpButton1", true, false)
	var up_button_2 = _initials_entry.find_child("UpButton2", true, false)

	if up_button_0 == null:
		_fail("Missing UpButton0 for slot 0")
		return
	if up_button_1 == null:
		_fail("Missing UpButton1 for slot 1")
		return
	if up_button_2 == null:
		_fail("Missing UpButton2 for slot 2")
		return

	print("Up buttons found for all slots")

	# Check for down buttons
	var down_button_0 = _initials_entry.find_child("DownButton0", true, false)
	var down_button_1 = _initials_entry.find_child("DownButton1", true, false)
	var down_button_2 = _initials_entry.find_child("DownButton2", true, false)

	if down_button_0 == null:
		_fail("Missing DownButton0 for slot 0")
		return
	if down_button_1 == null:
		_fail("Missing DownButton1 for slot 1")
		return
	if down_button_2 == null:
		_fail("Missing DownButton2 for slot 2")
		return

	print("Down buttons found for all slots")

	# Check for OK button
	var ok_button = _initials_entry.find_child("OKButton", true, false)
	if ok_button == null:
		_fail("Missing OKButton for confirmation")
		return

	print("OK button found")

	# Test 2: Test touch input cycling letters via button press
	print("Testing touch input cycling...")

	# Start with default "AAA"
	var current = _initials_entry.get_initials()
	if current != "AAA":
		_fail("Expected default 'AAA', got '%s'" % current)
		return

	# Simulate pressing up button on slot 0 (should change A to B)
	up_button_0.emit_signal("pressed")
	await get_tree().process_frame

	current = _initials_entry.get_initials()
	print("After up button 0 press: '%s'" % current)

	if current[0] != "B":
		_fail("First letter should be 'B' after up button press, got '%s'" % current[0])
		return

	# Press up button 11 more times to get to M (B->C->...->M)
	for i in range(11):
		up_button_0.emit_signal("pressed")
		await get_tree().process_frame

	current = _initials_entry.get_initials()
	print("After total 12 up presses on slot 0: '%s'" % current)

	if current[0] != "M":
		_fail("First letter should be 'M', got '%s'" % current[0])
		return

	# Test slot 1: Press up 9 times (A->J)
	for i in range(9):
		up_button_1.emit_signal("pressed")
		await get_tree().process_frame

	current = _initials_entry.get_initials()
	print("After 9 up presses on slot 1: '%s'" % current)

	if current[1] != "J":
		_fail("Second letter should be 'J', got '%s'" % current[1])
		return

	# Test slot 2: Press up 10 times (A->K)
	for i in range(10):
		up_button_2.emit_signal("pressed")
		await get_tree().process_frame

	current = _initials_entry.get_initials()
	print("After 10 up presses on slot 2: '%s'" % current)

	if current[2] != "K":
		_fail("Third letter should be 'K', got '%s'" % current[2])
		return

	# Test down button (K -> J)
	down_button_2.emit_signal("pressed")
	await get_tree().process_frame

	current = _initials_entry.get_initials()
	print("After down button on slot 2: '%s'" % current)

	if current[2] != "J":
		_fail("Third letter should be 'J' after down press, got '%s'" % current[2])
		return

	# Press up once more to get back to K
	up_button_2.emit_signal("pressed")
	await get_tree().process_frame

	# Final check before confirm
	current = _initials_entry.get_initials()
	print("Final initials before OK: '%s'" % current)

	if current != "MJK":
		_fail("Expected 'MJK' before confirm, got '%s'" % current)
		return

	# Test 3: OK button confirms initials
	print("Testing OK button confirmation...")
	ok_button.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for signal

	if _confirmed_initials != "MJK":
		_fail("Confirmed initials should be 'MJK', got '%s'" % _confirmed_initials)
		return

	# Test 4: Verify touch and keyboard work interchangeably
	# Reset and test mixing inputs
	print("Testing mixed touch/keyboard input...")

	# Reload component to reset state
	_initials_entry.queue_free()
	await get_tree().process_frame

	_initials_entry = load("res://scenes/ui/initials_entry.tscn").instantiate()
	add_child(_initials_entry)
	_initials_entry.initials_confirmed.connect(_on_initials_confirmed)
	_initials_entry.show_entry()
	await get_tree().process_frame

	_confirmed_initials = ""

	# Use touch for first letter
	var new_up_0 = _initials_entry.find_child("UpButton0", true, false)
	new_up_0.emit_signal("pressed")
	await get_tree().process_frame

	current = _initials_entry.get_initials()
	if current[0] != "B":
		_fail("Touch input not working after reload")
		return

	# Use keyboard for second letter
	_simulate_key_press(KEY_RIGHT)  # Move to slot 1
	await get_tree().process_frame
	_simulate_key_press(KEY_UP)  # Change to B
	await get_tree().process_frame

	current = _initials_entry.get_initials()
	print("After mixed input: '%s'" % current)

	if current != "BBA":
		_fail("Mixed input should give 'BBA', got '%s'" % current)
		return

	print("Mixed touch/keyboard input works correctly")

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
	print("InitialsEntry touch controls work correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
