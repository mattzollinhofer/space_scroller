extends Node2D
## Integration test: Main menu has Level Select button that navigates to level select screen
## Run this scene to verify level select menu functionality works end-to-end.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level Select Button on Main Menu ===")

	# Load main menu scene
	var menu_scene = load("res://scenes/ui/main_menu.tscn")
	if not menu_scene:
		_fail("Could not load main menu scene at res://scenes/ui/main_menu.tscn")
		return

	var main_menu = menu_scene.instantiate()
	add_child(main_menu)

	# Find Level Select button
	var level_select_button = _find_button_by_text(main_menu, "Level Select")
	if not level_select_button:
		level_select_button = _find_node_by_name(main_menu, "LevelSelectButton") as Button

	if not level_select_button:
		_fail("Level Select button not found in main menu")
		return

	print("Level Select button found: %s" % level_select_button.text)

	# Verify it's between Play and Character Select (check parent's children order)
	var vbox = level_select_button.get_parent()
	if vbox:
		var button_index = level_select_button.get_index()
		var play_button = _find_button_by_text(main_menu, "Play")
		var char_button = _find_button_by_text(main_menu, "Character")

		if play_button and char_button:
			var play_index = play_button.get_index()
			var char_index = char_button.get_index()

			if not (play_index < button_index and button_index < char_index):
				_fail("Level Select button should be between Play and Character Select buttons")
				return
			print("Level Select button positioned correctly between Play and Character Select")

	# Verify main menu script has the correct handler method
	if not main_menu.has_method("_on_level_select_button_pressed"):
		_fail("Main menu missing _on_level_select_button_pressed method")
		return

	print("Level Select button handler method exists")

	# Verify the Level Select button is connected
	if not level_select_button.pressed.is_connected(main_menu._on_level_select_button_pressed):
		_fail("Level Select button not connected to _on_level_select_button_pressed")
		return

	print("Level Select button is properly connected to handler")

	# Test that level select scene exists and can be loaded
	var level_select_scene = load("res://scenes/ui/level_select.tscn")
	if not level_select_scene:
		_fail("Could not load level select scene at res://scenes/ui/level_select.tscn")
		return

	print("Level select scene loaded successfully")

	# Instantiate level select scene and verify Level 1 is shown
	var level_select = level_select_scene.instantiate()
	add_child(level_select)

	# Find Level 1 button on level select screen
	var level1_button = _find_button_by_text(level_select, "Level 1")
	if not level1_button:
		level1_button = _find_node_by_name(level_select, "Level1Button") as Button

	if not level1_button:
		_fail("Level 1 button not found in level select screen")
		return

	print("Level 1 button found: %s" % level1_button.text)

	# Level 1 should be available (not disabled)
	if level1_button.disabled:
		_fail("Level 1 button should not be disabled")
		return

	print("Level 1 is available (not disabled)")

	# All checks passed
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
	print("Level Select button exists on main menu and level select screen shows Level 1.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
