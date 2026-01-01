extends Node2D
## Integration test: Level 5 button appears in level select screen and can be clicked.
## Verifies Level 5 is accessible from the UI.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level 5 Button in Level Select ===")

	# Load level select scene
	var level_select_scene = load("res://scenes/ui/level_select.tscn")
	if not level_select_scene:
		_fail("Could not load level select scene at res://scenes/ui/level_select.tscn")
		return

	var level_select = level_select_scene.instantiate()
	add_child(level_select)

	# Find Level 5 button
	var level5_button = _find_button_by_text(level_select, "Level 5")
	if not level5_button:
		level5_button = _find_node_by_name(level_select, "Level5Button") as Button

	if not level5_button:
		_fail("Level 5 button not found in level select")
		return

	print("Level 5 button found: %s" % level5_button.text)

	# Verify button is not disabled
	if level5_button.disabled:
		_fail("Level 5 button should not be disabled")
		return

	print("Level 5 button is enabled")

	# Verify the level select script has the _on_level_selected method
	if not level_select.has_method("_on_level_selected"):
		_fail("Level select missing _on_level_selected method")
		return

	print("Level select has _on_level_selected method")

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
	print("Level 5 button exists and is selectable in level select.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
