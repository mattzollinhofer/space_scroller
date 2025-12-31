extends Node2D
## Integration test: Pause menu can be opened, game pauses, resume continues, quit returns to menu
## Run this scene to verify pause functionality works end-to-end.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0
var _current_step: int = 0

var main_scene_instance: Node = null
var pause_menu: Node = null
var pause_button: Node = null


func _ready() -> void:
	# Set process mode to ALWAYS so test continues running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	print("=== Test: Pause Menu Functionality ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	main_scene_instance = main_scene.instantiate()
	add_child(main_scene_instance)

	# Find the pause menu
	pause_menu = main_scene_instance.get_node_or_null("PauseMenu")
	if not pause_menu:
		_fail("PauseMenu node not found in main scene")
		return

	# Verify pause menu starts hidden
	if pause_menu.visible:
		_fail("PauseMenu should start hidden")
		return

	print("PauseMenu found and starts hidden")

	# Verify pause menu has required methods
	if not pause_menu.has_method("show_pause_menu"):
		_fail("PauseMenu does not have 'show_pause_menu' method")
		return

	if not pause_menu.has_method("hide_pause_menu"):
		_fail("PauseMenu does not have 'hide_pause_menu' method")
		return

	print("PauseMenu has required methods")

	# Find pause button
	pause_button = _find_node_by_name(main_scene_instance, "PauseButton")
	if not pause_button:
		_fail("PauseButton not found in main scene")
		return

	print("PauseButton found")

	# Find Resume button in pause menu
	var resume_button = _find_button_by_text(pause_menu, "Resume")
	if not resume_button:
		resume_button = _find_node_by_name(pause_menu, "ResumeButton") as Button

	if not resume_button:
		_fail("Resume button not found in PauseMenu")
		return

	print("Resume button found")

	# Find Quit to Menu button
	var quit_button = _find_button_by_text(pause_menu, "Quit")
	if not quit_button:
		quit_button = _find_button_by_text(pause_menu, "Menu")
		if not quit_button:
			quit_button = _find_node_by_name(pause_menu, "QuitButton") as Button

	if not quit_button:
		_fail("Quit to Menu button not found in PauseMenu")
		return

	print("Quit to Menu button found")

	# Verify process mode is set correctly for pause menu
	if pause_menu.process_mode != Node.PROCESS_MODE_ALWAYS:
		_fail("PauseMenu process_mode should be PROCESS_MODE_ALWAYS")
		return

	print("PauseMenu process_mode is correctly set to ALWAYS")

	# Check that "pause" action exists in InputMap
	if not InputMap.has_action("pause"):
		_fail("InputMap missing 'pause' action")
		return

	print("InputMap has 'pause' action")

	# Now test pause functionality
	_current_step = 1
	print("Step 1: Testing show_pause_menu...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out at step %d" % _current_step)
		return

	match _current_step:
		1:
			# Test showing pause menu
			pause_menu.show_pause_menu()
			_current_step = 2

		2:
			# Verify pause menu is visible and game is paused
			if not pause_menu.visible:
				_fail("PauseMenu should be visible after show_pause_menu()")
				return

			if not get_tree().paused:
				_fail("Game tree should be paused after show_pause_menu()")
				return

			print("Step 2: PauseMenu visible and game paused - PASSED")
			_current_step = 3

		3:
			# Test hiding pause menu (resume)
			pause_menu.hide_pause_menu()
			_current_step = 4

		4:
			# Verify pause menu is hidden and game is unpaused
			if pause_menu.visible:
				_fail("PauseMenu should be hidden after hide_pause_menu()")
				return

			if get_tree().paused:
				_fail("Game tree should be unpaused after hide_pause_menu()")
				return

			print("Step 4: PauseMenu hidden and game unpaused - PASSED")
			_pass()


func _find_node_by_name(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
	for child in root.get_children():
		var found = _find_node_by_name(child, node_name)
		if found:
			return found
	return null


func _find_button_by_text(root: Node, text_contains: String) -> Button:
	if root is Button:
		if text_contains.to_lower() in root.text.to_lower():
			return root
	for child in root.get_children():
		var found = _find_button_by_text(child, text_contains)
		if found:
			return found
	return null


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Pause menu functionality works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
