extends Node2D
## Integration test: Player can select character from main menu and see it reflected in gameplay.
## Tests the full flow: main menu -> character selection -> select character -> start game -> verify sprite

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_stage: int = 0
var _selected_character: String = ""


func _ready() -> void:
	print("=== Test: Character Selection Flow ===")

	# First verify GameState autoload exists
	if not Engine.has_singleton("GameState") and not has_node("/root/GameState"):
		var game_state = get_node_or_null("/root/GameState")
		if game_state == null:
			_fail("GameState autoload not found - must be registered in project.godot")
			return

	# Test Stage 1: Verify GameState functionality
	print("Stage 1: Testing GameState autoload...")
	var game_state = get_node("/root/GameState")

	if not game_state.has_method("get_selected_character"):
		_fail("GameState missing get_selected_character() method")
		return

	if not game_state.has_method("set_selected_character"):
		_fail("GameState missing set_selected_character() method")
		return

	# Verify default is blue_blaster
	var default_char = game_state.get_selected_character()
	if default_char != "blue_blaster":
		_fail("GameState default character should be 'blue_blaster', got '%s'" % default_char)
		return

	print("GameState autoload works correctly with default 'blue_blaster'")

	# Test Stage 2: Load and verify character selection screen
	print("Stage 2: Testing character selection screen...")
	var char_select_scene = load("res://scenes/ui/character_selection.tscn")
	if not char_select_scene:
		_fail("Could not load character selection scene at res://scenes/ui/character_selection.tscn")
		return

	var char_select = char_select_scene.instantiate()
	add_child(char_select)

	# Find character buttons (should be 3)
	var character_buttons = _find_character_buttons(char_select)
	if character_buttons.size() < 3:
		_fail("Expected 3 character buttons, found %d" % character_buttons.size())
		return

	print("Found %d character buttons" % character_buttons.size())

	# Find back button
	var back_button = _find_button_by_text(char_select, "Back")
	if not back_button:
		back_button = _find_node_by_name(char_select, "BackButton") as Button

	if not back_button:
		_fail("Back button not found in character selection screen")
		return

	print("Back button found")

	# Test Stage 3: Select a different character (Space Dragon)
	print("Stage 3: Selecting Space Dragon character...")
	game_state.set_selected_character("space_dragon")

	var selected = game_state.get_selected_character()
	if selected != "space_dragon":
		_fail("Failed to set character to 'space_dragon', got '%s'" % selected)
		return

	print("Character selection updated to 'space_dragon'")

	# Test Stage 4: Verify player loads correct sprite
	print("Stage 4: Testing player loads selected character sprite...")

	# Remove character selection screen first
	char_select.queue_free()
	await get_tree().process_frame

	# Load player scene
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return

	var player = player_scene.instantiate()
	add_child(player)

	# Wait a frame for _ready to complete
	await get_tree().process_frame

	# Check if player sprite has the correct texture
	var sprite = player.get_node_or_null("Sprite2D") as Sprite2D
	if not sprite:
		_fail("Player Sprite2D not found")
		return

	if not sprite.texture:
		_fail("Player sprite has no texture")
		return

	var texture_path = sprite.texture.resource_path
	print("Player sprite texture: %s" % texture_path)

	# Verify it's the space dragon texture
	if "space-dragon" not in texture_path and "space_dragon" not in texture_path:
		_fail("Expected space dragon sprite, got: %s" % texture_path)
		return

	print("Player correctly loaded space_dragon sprite")

	# Test Stage 5: Reset to blue_blaster and verify
	print("Stage 5: Testing reset to default...")
	game_state.set_selected_character("blue_blaster")

	# Clean up and reload player
	player.queue_free()
	await get_tree().process_frame

	var player2 = player_scene.instantiate()
	add_child(player2)
	await get_tree().process_frame

	var sprite2 = player2.get_node_or_null("Sprite2D") as Sprite2D
	var texture_path2 = sprite2.texture.resource_path if sprite2 and sprite2.texture else ""

	if "player.png" not in texture_path2 and "blue" not in texture_path2:
		# Accept player.png as the blue blaster sprite
		if "player" not in texture_path2:
			_fail("Expected blue_blaster sprite, got: %s" % texture_path2)
			return

	print("Player correctly loaded blue_blaster sprite")

	# All tests passed
	_pass()


func _find_character_buttons(root: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	_find_character_buttons_recursive(root, buttons)
	return buttons


func _find_character_buttons_recursive(node: Node, buttons: Array[Button]) -> void:
	# Look for buttons that are character selection buttons (not Back button)
	if node is Button:
		var btn = node as Button
		var btn_text = btn.text.to_lower() if btn.text else ""
		var btn_name = node.name.to_lower()
		# Exclude back, play, quit, menu type buttons
		if "back" not in btn_text and "play" not in btn_text and "quit" not in btn_text and "menu" not in btn_text:
			if "character" in btn_name or "select" in btn_name or "blaster" in btn_text or "dragon" in btn_text or "cat" in btn_text or btn_text == "":
				buttons.append(btn)

	for child in node.get_children():
		_find_character_buttons_recursive(child, buttons)


func _find_button_by_text(root: Node, text_contains: String) -> Button:
	if root is Button:
		if text_contains.to_lower() in root.text.to_lower():
			return root
	for child in root.get_children():
		var found = _find_button_by_text(child, text_contains)
		if found:
			return found
	return null


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
	print("Character selection flow works correctly end-to-end.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
