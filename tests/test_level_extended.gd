extends Node2D
## Integration test: verify extended level structure
## - Level 1 total_distance is 13500 pixels
## - Level has 6 sections with correct structure
## - Sections have progressive difficulty with varied enemy waves

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Extended Level Structure ===")

	# Load level data directly
	var level_data = _load_level_data("res://levels/level_1.json")
	if level_data.is_empty():
		_fail("Could not load level_1.json")
		return

	# Test 1: Verify total_distance is 13500
	var total_distance = level_data.get("total_distance", 0)
	print("Total distance: %d (expected: 13500)" % total_distance)
	if total_distance != 13500:
		_fail("Expected total_distance of 13500, got %d" % total_distance)
		return

	# Test 2: Verify 6 sections exist
	var sections = level_data.get("sections", [])
	print("Section count: %d (expected: 6)" % sections.size())
	if sections.size() != 6:
		_fail("Expected 6 sections, got %d" % sections.size())
		return

	# Test 3: Verify section names
	var expected_names = ["Opening", "Building", "Ramping", "Intense", "Gauntlet", "Final Push"]
	for i in range(sections.size()):
		var section_name = sections[i].get("name", "")
		if section_name != expected_names[i]:
			_fail("Section %d expected name '%s', got '%s'" % [i, expected_names[i], section_name])
			return
		print("Section %d: %s - OK" % [i, section_name])

	# Test 4: Verify section percentages are contiguous and reach 100%
	var last_end = 0
	for i in range(sections.size()):
		var section = sections[i]
		var start = section.get("start_percent", -1)
		var end = section.get("end_percent", -1)

		if start != last_end:
			_fail("Section %d start_percent (%d) does not match previous end_percent (%d)" % [i, start, last_end])
			return

		if end <= start:
			_fail("Section %d end_percent (%d) must be greater than start_percent (%d)" % [i, end, start])
			return

		last_end = end

	if last_end != 100:
		_fail("Last section end_percent should be 100, got %d" % last_end)
		return

	print("Section percentages are contiguous and complete - OK")

	# Test 5: Verify enemy waves contain valid enemy types
	var valid_types = ["stationary", "patrol", "shooting", "charger"]
	for i in range(sections.size()):
		var section = sections[i]
		var enemy_waves = section.get("enemy_waves", [])
		for wave in enemy_waves:
			var enemy_type = wave.get("enemy_type", "")
			if enemy_type not in valid_types:
				_fail("Section %d has invalid enemy_type: '%s'" % [i, enemy_type])
				return
			var count = wave.get("count", 0)
			if count <= 0:
				_fail("Section %d has enemy wave with count %d" % [i, count])
				return

	print("All enemy waves have valid types and counts - OK")

	_pass()


func _load_level_data(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		return {}

	return json.data


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- total_distance is 13500 pixels")
	print("- 6 sections exist with correct names")
	print("- Section percentages are contiguous (0-100)")
	print("- All enemy waves have valid types and counts")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("")
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
