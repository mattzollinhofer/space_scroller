extends Node2D
## Integration test: Player dies in section 0, game over screen is shown
## Run this scene to verify game over still works when there's no checkpoint.

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 8.0
var _timer: float = 0.0

var level_manager: Node = null
var player: Node = null
var game_over_screen: Node = null
var scroll_controller: Node = null
var _player_died: bool = false


func _ready() -> void:
	print("=== Test: Section 0 Game Over ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Find level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found")
		return

	# Find player
	player = main.get_node_or_null("Player")
	if not player:
		_fail("Player node not found")
		return

	# Find game over screen
	game_over_screen = main.get_node_or_null("GameOverScreen")
	if not game_over_screen:
		_fail("GameOverScreen node not found")
		return

	# Stop scrolling - stay in section 0
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 0.0

	# Wait for scene to fully initialize (section change to 0 should happen)
	await TestHelpers.poll_until(get_tree(), func(): return level_manager.get_current_section() == 0, 3.0)

	var current_section = level_manager.get_current_section()
	var has_checkpoint = level_manager.has_checkpoint()
	print("Current section: %s, has checkpoint: %s" % [current_section, has_checkpoint])

	# Verify we're in section 0 and have no checkpoint
	if current_section != 0:
		_fail("Not in section 0 (current: %s)" % current_section)
		return

	if has_checkpoint:
		_fail("Should not have checkpoint in section 0")
		return

	print("In section 0 with no checkpoint. Triggering player death...")
	_trigger_player_death()


func _trigger_player_death() -> void:
	if not player:
		return

	var initial_lives = player.get_lives()
	print("Player has %s lives" % initial_lives)

	# Reach game over fast: set the player to its last life with 1 health so a
	# single hit is fatal, instead of spacing many hits past 1.5s invincibility
	# windows (which took ~14s). Death transition itself is still exercised.
	player._lives = 1
	player._health = 1
	await get_tree().process_frame

	player.take_damage()
	_player_died = true
	print("Player death triggered, lives: %s" % player.get_lives())

	# Wait for the game over screen to appear (poll instead of a blind sleep)
	await TestHelpers.poll_until(get_tree(), func(): return game_over_screen.visible, 3.0)
	_check_game_over()


func _check_game_over() -> void:
	if _test_passed or _test_failed:
		return

	# Check if game over screen is visible (should be since we have no checkpoint)
	print("Checking game over screen visibility: %s" % game_over_screen.visible)
	if game_over_screen and game_over_screen.visible:
		print("Game over screen is visible")
		_pass()
	else:
		_fail("Game over screen not shown (visible: %s)" % (game_over_screen.visible if game_over_screen else "null"))


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
	print("Game over shows when dying in section 0.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
