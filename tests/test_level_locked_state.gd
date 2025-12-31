extends Node2D
## Integration test: Level 2 and 3 buttons show locked state when not unlocked
## Verifies that locked levels appear disabled and grayed out.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level 2 and 3 Locked State ===")

	# Reset any unlock state for clean test
	_reset_unlock_state()

	# Load level select scene
	var level_select_scene = load("res://scenes/ui/level_select.tscn")
	if not level_select_scene:
		_fail("Could not load level select scene at res://scenes/ui/level_select.tscn")
		return

	var level_select = level_select_scene.instantiate()
	add_child(level_select)

	# Wait a frame for _ready to complete
	await get_tree().process_frame

	# Find Level 2 button
	var level2_button = _find_button_by_text(level_select, "Level 2")
	if not level2_button:
		level2_button = _find_node_by_name(level_select, "Level2Button") as Button

	if not level2_button:
		_fail("Level 2 button not found in level select")
		return

	print("Level 2 button found")

	# Verify Level 2 button is disabled
	if not level2_button.disabled:
		_fail("Level 2 button should be disabled when not unlocked")
		return

	print("Level 2 button is correctly disabled")

	# Find Level 3 button
	var level3_button = _find_button_by_text(level_select, "Level 3")
	if not level3_button:
		level3_button = _find_node_by_name(level_select, "Level3Button") as Button

	if not level3_button:
		_fail("Level 3 button not found in level select")
		return

	print("Level 3 button found")

	# Verify Level 3 button is disabled
	if not level3_button.disabled:
		_fail("Level 3 button should be disabled when not unlocked")
		return

	print("Level 3 button is correctly disabled")

	# All checks passed
	_pass()


func _reset_unlock_state() -> void:
	# Clear level unlock state from ScoreManager if available
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("reset_level_unlocks"):
			score_manager.reset_level_unlocks()


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
	print("Level 2 and 3 buttons correctly show locked state.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
