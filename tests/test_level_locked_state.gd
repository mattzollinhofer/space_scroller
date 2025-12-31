extends Node2D
## Integration test: All levels are selectable from level select
## Verifies that all level buttons are enabled and properly styled.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: All Levels Selectable ===")

	# Load level select scene
	var level_select_scene = load("res://scenes/ui/level_select.tscn")
	if not level_select_scene:
		_fail("Could not load level select scene at res://scenes/ui/level_select.tscn")
		return

	var level_select = level_select_scene.instantiate()
	add_child(level_select)

	# Wait a frame for _ready to complete
	await get_tree().process_frame

	# Find and verify all level buttons are enabled
	var level1_button = _find_node_by_name(level_select, "Level1Button") as Button
	var level2_button = _find_node_by_name(level_select, "Level2Button") as Button
	var level3_button = _find_node_by_name(level_select, "Level3Button") as Button

	if not level1_button:
		_fail("Level 1 button not found in level select")
		return

	if not level2_button:
		_fail("Level 2 button not found in level select")
		return

	if not level3_button:
		_fail("Level 3 button not found in level select")
		return

	print("All level buttons found")

	# Verify all buttons are enabled (selectable)
	if level1_button.disabled:
		_fail("Level 1 button should be enabled")
		return
	print("Level 1 button is enabled")

	if level2_button.disabled:
		_fail("Level 2 button should be enabled")
		return
	print("Level 2 button is enabled")

	if level3_button.disabled:
		_fail("Level 3 button should be enabled")
		return
	print("Level 3 button is enabled")

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


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("All levels are selectable from level select.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
