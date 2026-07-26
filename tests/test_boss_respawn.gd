extends Node2D
## Integration test: Player death during the boss fight shows game over.
## The old "respawn at boss entrance" behavior was intentionally removed
## ("No infinite respawns regardless of boss fight or checkpoint status"), so
## dying during the boss fight ends the run like anywhere else.

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
var main: Node = null
var _boss: Node = null
var _boss_spawned: bool = false
var _player_died: bool = false


func _ready() -> void:
	print("=== Test: Player Death During Boss Fight Shows Game Over ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	main = main_scene.instantiate()
	add_child(main)

	# Find level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found")
		return

	# Connect to boss_spawned signal
	if level_manager.has_signal("boss_spawned"):
		level_manager.boss_spawned.connect(_on_boss_spawned)
	else:
		_fail("LevelManager does not have 'boss_spawned' signal")
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

	# Speed up scroll to reach the boss quickly
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for boss to spawn...")


func _on_boss_spawned() -> void:
	print("Boss spawned!")
	_boss_spawned = true

	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else main.get_node_or_null("Boss")
	if not _boss:
		_fail("Boss not found after spawn")
		return

	# Wait for the boss entrance to finish (it ignores damage until then) instead
	# of a fixed sleep.
	var entered := await TestHelpers.poll_until(get_tree(), func(): return _boss and _boss._entrance_complete, 5.0)
	if not entered:
		_fail("Boss entrance never completed")
		return

	print("Boss fight underway. Triggering player death...")
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

	# Death during the boss fight must still end the run: poll for the game over
	# screen rather than a blind sleep.
	await TestHelpers.poll_until(get_tree(), func(): return game_over_screen.visible, 3.0)
	_check_game_over()


func _check_game_over() -> void:
	if _test_passed or _test_failed:
		return

	if game_over_screen and game_over_screen.visible:
		print("Game over screen is visible (no boss respawn, as intended)")
		_pass()
	else:
		_fail("Game over screen not shown after death during boss fight (visible: %s)" % (game_over_screen.visible if game_over_screen else "null"))


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		if not _boss_spawned:
			_fail("Test timed out - boss never spawned")
		elif not _player_died:
			_fail("Test timed out - player death not triggered")
		else:
			_fail("Test timed out - game over not verified")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Dying during the boss fight shows game over (no respawn).")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
