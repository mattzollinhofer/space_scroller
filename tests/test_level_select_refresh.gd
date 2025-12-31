extends Node
## Test that level select screen shows all levels as selectable


func _ready() -> void:
	print("=== Test: Level Select All Levels Selectable ===")

	# Load level select scene
	var level_select_scene = load("res://scenes/ui/level_select.tscn")
	if not level_select_scene:
		print("ERROR: Failed to load level_select.tscn")
		get_tree().quit(1)
		return

	var level_select = level_select_scene.instantiate()
	add_child(level_select)

	# Wait a frame for _ready to complete
	await get_tree().process_frame

	# Find all level buttons
	var level1_button = level_select.get_node_or_null("CenterContainer/VBoxContainer/LevelGrid/Level1Button")
	var level2_button = level_select.get_node_or_null("CenterContainer/VBoxContainer/LevelGrid/Level2Button")
	var level3_button = level_select.get_node_or_null("CenterContainer/VBoxContainer/LevelGrid/Level3Button")

	if not level1_button or not level2_button or not level3_button:
		print("ERROR: Not all level buttons found")
		get_tree().quit(1)
		return

	# Verify all levels are enabled (selectable)
	if level1_button.disabled:
		print("ERROR: Level 1 should be enabled")
		get_tree().quit(1)
		return
	print("Level 1 button is enabled (correct)")

	if level2_button.disabled:
		print("ERROR: Level 2 should be enabled")
		get_tree().quit(1)
		return
	print("Level 2 button is enabled (correct)")

	if level3_button.disabled:
		print("ERROR: Level 3 should be enabled")
		get_tree().quit(1)
		return
	print("Level 3 button is enabled (correct)")

	# Cleanup
	level_select.queue_free()

	print("")
	print("=== TEST PASSED ===")
	print("All levels are selectable from level select.")
	get_tree().quit(0)
