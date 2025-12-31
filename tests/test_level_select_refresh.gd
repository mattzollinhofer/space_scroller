extends Node
## Test that level select screen refreshes unlock state when shown


func _ready() -> void:
	print("=== Test: Level Select Refresh on Show ===")

	# Get ScoreManager
	if not has_node("/root/ScoreManager"):
		print("ERROR: ScoreManager not found")
		get_tree().quit(1)
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reset unlocks
	if score_manager.has_method("reset_level_unlocks"):
		score_manager.reset_level_unlocks()

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

	# Find Level 2 button
	var level2_button = level_select.get_node_or_null("CenterContainer/VBoxContainer/LevelGrid/Level2Button")
	if not level2_button:
		print("ERROR: Level 2 button not found")
		get_tree().quit(1)
		return

	# Verify Level 2 is locked initially
	if not level2_button.disabled:
		print("ERROR: Level 2 should be disabled initially")
		get_tree().quit(1)
		return
	print("Level 2 button is disabled initially (correct)")

	# Now unlock Level 2 via ScoreManager
	score_manager.unlock_level(2)
	print("Level 2 unlocked via ScoreManager")

	# Call _update_button_states (simulating what happens on scene reload)
	if level_select.has_method("_update_button_states"):
		level_select._update_button_states()
	else:
		print("ERROR: _update_button_states method not found")
		get_tree().quit(1)
		return

	# Verify Level 2 button is now enabled
	if level2_button.disabled:
		print("ERROR: Level 2 should be enabled after refresh")
		get_tree().quit(1)
		return
	print("Level 2 button is enabled after refresh (correct)")

	# Cleanup
	level_select.queue_free()
	score_manager.reset_level_unlocks()

	print("")
	print("=== TEST PASSED ===")
	print("Level select correctly refreshes unlock state.")
	get_tree().quit(0)
