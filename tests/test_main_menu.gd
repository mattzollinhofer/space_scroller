extends Node2D
## Integration test: Main menu displays on launch with Play button that starts gameplay
## Run this scene to verify main menu functionality works end-to-end.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Main Menu Display and Play Button ===")

	# Load main menu scene
	var menu_scene = load("res://scenes/ui/main_menu.tscn")
	if not menu_scene:
		_fail("Could not load main menu scene at res://scenes/ui/main_menu.tscn")
		return

	var main_menu = menu_scene.instantiate()
	add_child(main_menu)

	# Check for title label
	var title_label = _find_node_by_type_and_text(main_menu, "Label", "Solar System Showdown")
	if not title_label:
		title_label = _find_node_by_name(main_menu, "TitleLabel")
		if not title_label:
			title_label = _find_node_by_name(main_menu, "Title")

	if not title_label:
		_fail("Title label not found in main menu")
		return

	print("Title label found: %s" % title_label.text if title_label is Label else "found")

	# Find Play button
	var play_button = _find_button_by_text(main_menu, "Play")
	if not play_button:
		play_button = _find_node_by_name(main_menu, "PlayButton") as Button

	if not play_button:
		_fail("Play button not found in main menu")
		return

	print("Play button found and visible: %s" % play_button.visible)

	# Check for High Scores button (should be disabled)
	var high_scores_button = _find_button_by_text(main_menu, "High Scores")
	if not high_scores_button:
		high_scores_button = _find_node_by_name(main_menu, "HighScoresButton") as Button

	if high_scores_button:
		if not high_scores_button.disabled:
			_fail("High Scores button should be disabled (placeholder)")
			return
		print("High Scores button found and disabled (placeholder)")
	else:
		_fail("High Scores button not found in main menu")
		return

	# Check for Character Selection button
	var char_select_button = _find_button_by_text(main_menu, "Character")
	if not char_select_button:
		char_select_button = _find_node_by_name(main_menu, "CharacterSelectButton") as Button

	if char_select_button:
		print("Character Selection button found")
	else:
		_fail("Character Selection button not found in main menu")
		return

	# Verify main menu script has the correct method for Play button
	if not main_menu.has_method("_on_play_button_pressed"):
		_fail("Main menu missing _on_play_button_pressed method")
		return

	print("Play button handler method exists")

	# Verify the Play button is connected
	if not play_button.pressed.is_connected(main_menu._on_play_button_pressed):
		_fail("Play button not connected to _on_play_button_pressed")
		return

	print("Play button is properly connected to handler")

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


func _find_node_by_type_and_text(root: Node, type_name: String, text_contains: String) -> Node:
	if root.get_class() == type_name or root is Label:
		if root is Label and text_contains.to_lower() in root.text.to_lower():
			return root
	for child in root.get_children():
		var found = _find_node_by_type_and_text(child, type_name, text_contains)
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
	print("Main menu displays correctly with all required UI elements.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
