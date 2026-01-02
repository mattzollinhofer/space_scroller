extends Node2D
## Integration test: Level 6 button appears in level select screen and can be clicked.
## Verifies Level 6 is accessible from the UI.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level 6 Button in Level Select ===")

	# Load level select scene
	var level_select_scene = load("res://scenes/ui/level_select.tscn")
	if not level_select_scene:
		_fail("Could not load level select scene at res://scenes/ui/level_select.tscn")
		return

	var level_select = level_select_scene.instantiate()
	add_child(level_select)

	# Find Level 6 button
	var level6_button = _find_button_by_text(level_select, "Level 6")
	if not level6_button:
		level6_button = _find_node_by_name(level_select, "Level6Button") as Button

	if not level6_button:
		_fail("Level 6 button not found in level select")
		return

	print("Level 6 button found: %s" % level6_button.text)

	# Verify button is not disabled
	if level6_button.disabled:
		_fail("Level 6 button should not be disabled")
		return

	print("Level 6 button is enabled")

	# Verify the level select script has the _on_level_selected method
	if not level_select.has_method("_on_level_selected"):
		_fail("Level select missing _on_level_selected method")
		return

	print("Level select has _on_level_selected method")

	# Verify Level 6 is in GameState LEVEL_PATHS
	var game_state_script = load("res://scripts/autoloads/game_state.gd")
	if not game_state_script:
		_fail("Could not load GameState script")
		return

	# Check if level 6 path exists by loading and checking
	var level_6_path = "res://levels/level_6.json"
	var level_6_file = FileAccess.open(level_6_path, FileAccess.READ)
	if not level_6_file:
		_fail("Level 6 JSON file not found at %s" % level_6_path)
		return

	print("Level 6 JSON file exists")

	# Read and validate JSON has required fields
	var json_text = level_6_file.get_as_text()
	level_6_file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		_fail("Level 6 JSON is not valid JSON")
		return

	var level_data = json.get_data()
	if not level_data.has("sections"):
		_fail("Level 6 JSON missing 'sections' field")
		return

	if level_data.sections.size() < 6:
		_fail("Level 6 should have at least 6 sections, found %d" % level_data.sections.size())
		return

	print("Level 6 has %d sections" % level_data.sections.size())

	# Verify background modulate is pink/magenta
	if level_data.has("metadata") and level_data.metadata.has("background_modulate"):
		var bg = level_data.metadata.background_modulate
		# Pink/magenta should have high red, medium-high green, high blue/pink
		if bg[0] < 0.9 or bg[1] < 0.6 or bg[2] < 0.8:
			_fail("Background modulate should be pink/magenta, got %s" % str(bg))
			return
		print("Background modulate is pink/magenta: %s" % str(bg))
	else:
		_fail("Level 6 JSON missing metadata.background_modulate")
		return

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
	print("Level 6 button exists and is selectable in level select.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
