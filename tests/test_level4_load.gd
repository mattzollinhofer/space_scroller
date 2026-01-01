extends Node2D
## Integration test: Level 4 can be selected and loaded via GameState
## Verifies Level 4 exists in LEVEL_PATHS and the JSON file loads correctly.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level 4 Can Be Selected and Loaded ===")

	# Test 1: Verify Level 4 exists in GameState.LEVEL_PATHS
	if not has_node("/root/GameState"):
		_fail("GameState autoload not found")
		return

	var game_state = get_node("/root/GameState")

	# Check if level 4 is in LEVEL_PATHS
	if not 4 in game_state.LEVEL_PATHS:
		_fail("Level 4 not found in GameState.LEVEL_PATHS")
		return

	print("Level 4 found in LEVEL_PATHS")

	# Test 2: Verify level 4 path points to valid file
	var level4_path = game_state.LEVEL_PATHS[4]
	print("Level 4 path: %s" % level4_path)

	if not FileAccess.file_exists(level4_path):
		_fail("Level 4 JSON file does not exist at: %s" % level4_path)
		return

	print("Level 4 JSON file exists")

	# Test 3: Load and parse the JSON file
	var file = FileAccess.open(level4_path, FileAccess.READ)
	if not file:
		_fail("Could not open Level 4 JSON file")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		_fail("Failed to parse Level 4 JSON: %s" % json.get_error_message())
		return

	var level_data = json.data
	print("Level 4 JSON parsed successfully")

	# Test 4: Verify required fields
	if not "total_distance" in level_data:
		_fail("Level 4 JSON missing total_distance field")
		return

	if level_data.total_distance != 24000:
		_fail("Level 4 total_distance should be 24000, got: %d" % level_data.total_distance)
		return

	print("Level 4 total_distance: %d (correct)" % level_data.total_distance)

	# Test 5: Verify scroll_speed_multiplier in metadata
	if not "metadata" in level_data:
		_fail("Level 4 JSON missing metadata section")
		return

	if not "scroll_speed_multiplier" in level_data.metadata:
		_fail("Level 4 metadata missing scroll_speed_multiplier")
		return

	var scroll_speed = level_data.metadata.scroll_speed_multiplier
	if abs(scroll_speed - 1.3) > 0.01:
		_fail("Level 4 scroll_speed_multiplier should be 1.3, got: %f" % scroll_speed)
		return

	print("Level 4 scroll_speed_multiplier: %f (correct)" % scroll_speed)

	# Test 6: Verify sections exist with pizza-themed names
	if not "sections" in level_data:
		_fail("Level 4 JSON missing sections array")
		return

	var sections = level_data.sections
	if sections.size() < 6:
		_fail("Level 4 should have at least 6 sections, got: %d" % sections.size())
		return

	print("Level 4 has %d sections" % sections.size())

	# Verify pizza-themed section names exist
	var expected_section_names = [
		"Pizza Parlor Entry",
		"Cheese Caverns",
		"Pepperoni Pass",
		"Garlic Grove",
		"Mushroom Maze",
		"Final Feast"
	]

	for i in range(min(sections.size(), expected_section_names.size())):
		var section = sections[i]
		if not "name" in section:
			_fail("Section %d missing name field" % i)
			return
		if section.name != expected_section_names[i]:
			_fail("Section %d name should be '%s', got '%s'" % [i, expected_section_names[i], section.name])
			return
		print("Section %d: %s (correct)" % [i, section.name])

	# Test 7: Verify enemy_waves exist in sections
	for i in range(sections.size()):
		var section = sections[i]
		if not "enemy_waves" in section:
			_fail("Section %d '%s' missing enemy_waves" % [i, section.name])
			return
		if section.enemy_waves.size() == 0:
			_fail("Section %d '%s' has no enemy waves" % [i, section.name])
			return

	print("All sections have enemy waves configured")

	# Test 8: Verify GameState can select level 4
	game_state.set_selected_level(4)
	var selected_level = game_state.get_selected_level()
	if selected_level != 4:
		_fail("GameState.set_selected_level(4) failed, got level: %d" % selected_level)
		return

	print("GameState successfully selected Level 4")

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level 4 can be selected and loaded with correct configuration.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
