extends Node2D
## Integration test: Player dies in section 1+, respawns instead of game over
## Run this scene to verify checkpoint respawn works.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var level_manager: Node = null
var player: Node = null
var game_over_screen: Node = null
var scroll_controller: Node = null
var _reached_section_1: bool = false
var _player_died: bool = false
var _respawn_triggered: bool = false


func _ready() -> void:
	print("=== Test: Checkpoint Respawn ===")

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

	# Check for respawn_player method
	if not level_manager.has_method("respawn_player"):
		_fail("LevelManager does not have 'respawn_player' method")
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

	# Speed up scroll to reach section 1 quickly
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

		# Reduce player lives to 0 to trigger death
		_trigger_player_death()


func _trigger_player_death() -> void:
	if not player:
		return

	# Store initial lives
	var initial_lives = player.get_lives()
	print("Player has %s lives" % initial_lives)

	# Deal damage until dead
	for i in range(initial_lives + 1):
		player.take_damage()
		await get_tree().create_timer(0.1).timeout
		if player.get_lives() <= 0:
			break

	_player_died = true
	print("Player death triggered")

	# Wait a frame for respawn to process
	await get_tree().create_timer(0.5).timeout
	_check_respawn()


func _check_respawn() -> void:
	if _test_passed or _test_failed:
		return

	# Check if game over screen is visible (should NOT be if checkpoint respawn worked)
	if game_over_screen and game_over_screen.visible:
		_fail("Game over screen shown instead of checkpoint respawn")
		return

	# Check if player is still alive (respawned)
	if player and player.get_lives() > 0:
		_respawn_triggered = true
		print("Player respawned with %s lives" % player.get_lives())
		_pass()
	else:
		_fail("Player did not respawn (lives: %s)" % (player.get_lives() if player else "null"))


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
			_fail("Test timed out - respawn not verified")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Player respawns at checkpoint instead of game over.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
