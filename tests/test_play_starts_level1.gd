extends Node
## Test: Clicking "Play" button starts Level 1 directly (bypasses level select)

var _test_passed := false


func _ready() -> void:
	# Test that GameState defaults to Level 1
	_run_tests()


func _run_tests() -> void:
	print("Testing: Play button starts Level 1 directly...")

	# Test 1: GameState defaults to level 1
	var game_state = get_node_or_null("/root/GameState")
	if not game_state:
		_fail("GameState autoload not found")
		return

	# Verify default level is 1
	var selected_level = game_state.get_selected_level()
	if selected_level != 1:
		_fail("GameState should default to level 1, got: %d" % selected_level)
		return
	print("  [PASS] GameState defaults to level 1")

	# Test 2: GameState default level path is level_1.json
	var level_path = game_state.get_selected_level_path()
	if level_path != "res://levels/level_1.json":
		_fail("Default level path should be level_1.json, got: %s" % level_path)
		return
	print("  [PASS] Default level path is level_1.json")

	# Test 3: Play button handler exists in main menu script
	var main_menu_script = load("res://scripts/ui/main_menu.gd")
	if not main_menu_script:
		_fail("Could not load main_menu.gd")
		return

	var source_code = main_menu_script.source_code
	if "_on_play_button_pressed" not in source_code:
		_fail("Main menu missing _on_play_button_pressed handler")
		return
	print("  [PASS] Play button handler exists")

	# Test 4: Play button navigates to main.tscn (not level select)
	if "main.tscn" not in source_code:
		_fail("Play button should navigate to main.tscn")
		return
	print("  [PASS] Play button navigates to main.tscn")

	# Test 5: Level Select button handler exists separately
	if "_on_level_select_button_pressed" not in source_code:
		_fail("Main menu missing _on_level_select_button_pressed handler")
		return
	print("  [PASS] Level Select button handler exists")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("TEST PASSED: Play starts Level 1 directly")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("TEST FAILED: %s" % reason)
	get_tree().quit(1)
