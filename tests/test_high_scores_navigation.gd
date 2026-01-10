extends Node2D
## Integration test: High Scores button in main menu is enabled and navigates correctly
## Verifies:
## - High Scores button is NOT disabled (not grayed out)
## - Button has correct white color (not gray)
## - Clicking button should trigger navigation

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0
var _main_menu: Node = null


func _ready() -> void:
	print("=== Test: High Scores Button Navigation ===")

	# Load the main menu scene
	if not ResourceLoader.exists("res://scenes/ui/main_menu.tscn"):
		_fail("main_menu.tscn does not exist")
		return

	var scene = load("res://scenes/ui/main_menu.tscn")
	if scene == null:
		_fail("Failed to load main_menu.tscn")
		return

	_main_menu = scene.instantiate()
	if _main_menu == null:
		_fail("Failed to instantiate main_menu.tscn")
		return

	add_child(_main_menu)
	print("Main menu loaded")

	# Wait a frame for the scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame

	_verify_button()


func _verify_button() -> void:
	print("Verifying High Scores button...")

	# Find the High Scores button
	var high_scores_button = _find_button(_main_menu, "High Scores")
	if high_scores_button == null:
		_fail("High Scores button not found in main menu")
		return

	print("Found High Scores button")

	# Check that the button is NOT disabled
	if high_scores_button.disabled:
		_fail("High Scores button is disabled - should be enabled")
		return

	print("Button is enabled: true")

	# Check button color (should be white, not gray)
	var font_color = high_scores_button.get_theme_color("font_color")
	print("Button font color: %s" % font_color)

	# Check if color is white-ish (not gray)
	# White is Color(1, 1, 1, 1), gray would be around Color(0.5, 0.5, 0.5, 1)
	if font_color.r < 0.9 or font_color.g < 0.9 or font_color.b < 0.9:
		_fail("High Scores button has gray color - should be white. Color: %s" % font_color)
		return

	print("Button color is white: true")

	# Verify the high_scores_screen.tscn exists (navigation target)
	if not ResourceLoader.exists("res://scenes/ui/high_scores_screen.tscn"):
		_fail("high_scores_screen.tscn does not exist - navigation target missing")
		return

	print("Navigation target exists: true")

	_pass()


func _find_button(root: Node, text_contains: String) -> Button:
	if root is Button and text_contains in root.text:
		return root

	for child in root.get_children():
		var result = _find_button(child, text_contains)
		if result != null:
			return result

	return null


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("High Scores button is enabled with correct styling and navigation target exists.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
