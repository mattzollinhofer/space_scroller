extends Node2D
## Integration test: Player death after passing a checkpoint (section 1+) shows
## game over. The old "respawn at checkpoint" behavior was intentionally removed
## ("No infinite respawns regardless of boss fight or checkpoint status"), so
## death always ends the run.

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
var _reached_section_1: bool = false
var _player_died: bool = false


func _ready() -> void:
	print("=== Test: Death After Checkpoint Shows Game Over ===")

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

	# Connect to section changed
	level_manager.section_changed.connect(_on_section_changed)

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

	# Speed up scroll to cross the first checkpoint boundary (section 1) quickly
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 1800.0
		print("Speeding up scroll for test: 1800 px/s")

	print("Test setup complete. Waiting to reach section 1...")


func _on_section_changed(section_index: int) -> void:
	print("Section changed to: %s" % section_index)
	if section_index >= 1 and not _reached_section_1:
		_reached_section_1 = true
		print("Reached section 1. Now triggering player death...")
		# Stop scrolling and kill the player
		if scroll_controller:
			scroll_controller.scroll_speed = 0.0
		_trigger_player_death()


func _trigger_player_death() -> void:
	if not player:
		return

	# Reach game over fast: put the player on its last life with 1 health so a
	# single hit is fatal, rather than spacing many hits past invincibility windows.
	player._lives = 1
	player._health = 1
	await get_tree().process_frame

	player.take_damage()
	_player_died = true
	print("Player death triggered, lives: %s" % player.get_lives())

	# Death past a checkpoint must still end the run: poll for the game over screen
	# rather than a blind sleep.
	await TestHelpers.poll_until(get_tree(), func(): return game_over_screen.visible, 3.0)
	_check_game_over()


func _check_game_over() -> void:
	if _test_passed or _test_failed:
		return

	if game_over_screen and game_over_screen.visible:
		print("Game over screen is visible (no checkpoint respawn, as intended)")
		_pass()
	else:
		_fail("Game over screen not shown after death past checkpoint (visible: %s)" % (game_over_screen.visible if game_over_screen else "null"))


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		if not _reached_section_1:
			_fail("Test timed out - did not reach section 1")
		elif not _player_died:
			_fail("Test timed out - player death not triggered")
		else:
			_fail("Test timed out - game over not verified")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Dying after a checkpoint shows game over (no respawn).")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
