extends Node2D
## Integration test: Player respawns at boss entrance if defeated during fight
## Run this scene to verify player respawns instead of game over during boss fight.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 25.0
var _timer: float = 0.0

var level_manager: Node = null
var player: Node = null
var game_over_screen: Node = null
var scroll_controller: Node = null
var main: Node = null
var _boss: Node = null
var _boss_spawned: bool = false
var _player_died: bool = false
var _initial_boss_health: int = 0


func _ready() -> void:
	print("=== Test: Boss Respawn ===")

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

	# Connect to player_respawned signal
	if level_manager.has_signal("player_respawned"):
		level_manager.player_respawned.connect(_on_player_respawned)

	# Find player
	player = main.get_node_or_null("Player")
	if not player:
		_fail("Player node not found")
		return

	# Find game over screen
	game_over_screen = main.get_node_or_null("GameOverScreen")

	# Speed up scroll to reach 100% quickly
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for boss to spawn...")


func _on_boss_spawned() -> void:
	print("Boss spawned!")
	_boss_spawned = true

	# Wait for boss entrance to complete (entrance is 2s, add buffer)
	await get_tree().create_timer(2.5).timeout

	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else main.get_node_or_null("Boss")

	if not _boss:
		_fail("Boss not found after spawn")
		return

	# Record initial boss health
	_initial_boss_health = _boss.health if "health" in _boss else 13
	print("Boss health before player death: %s" % _initial_boss_health)

	# Check if boss fight is active
	var boss_fight_active = level_manager.is_boss_fight_active() if level_manager.has_method("is_boss_fight_active") else false
	print("Boss fight active: %s" % boss_fight_active)

	# Deal some damage to boss first (to verify it resets)
	if _boss.has_method("take_hit"):
		_boss.take_hit(3)
		await get_tree().create_timer(0.1).timeout
		print("Boss health after 3 damage: %s" % _boss.health)

	# Now kill the player
	_trigger_player_death()


func _on_player_respawned() -> void:
	print("Player respawned signal received!")


func _trigger_player_death() -> void:
	if not player:
		return

	var initial_lives = player.get_lives() if player.has_method("get_lives") else 3
	print("Player has %s lives" % initial_lives)

	# Disable invincibility to allow quick death
	if "_is_invincible" in player:
		player._is_invincible = false

	# Deal damage until dead, waiting for invincibility to expire
	var invincibility_wait = 1.6  # Slightly longer than invincibility_duration (1.5s)
	for i in range(initial_lives + 1):
		if player.has_method("take_damage"):
			# Disable invincibility before each hit
			if "_is_invincible" in player:
				player._is_invincible = false
			player.take_damage()
			var lives = player.get_lives() if player.has_method("get_lives") else 0
			print("After hit %s: lives = %s" % [i + 1, lives])
			if lives <= 0:
				print("Player died!")
				break
		await get_tree().create_timer(0.05).timeout

	_player_died = true
	print("Player death sequence complete")

	# Wait for respawn to process
	await get_tree().create_timer(0.5).timeout
	_check_respawn()


func _check_respawn() -> void:
	if _test_passed or _test_failed:
		return

	# Debug: check boss fight state
	var boss_fight_active = level_manager.is_boss_fight_active() if level_manager.has_method("is_boss_fight_active") else false
	print("Boss fight active after death: %s" % boss_fight_active)

	# Check 1: Game over screen should NOT be visible
	if game_over_screen and game_over_screen.visible:
		_fail("Game over screen shown instead of boss respawn")
		return

	# Check 2: Player should be alive (respawned)
	var player_lives = player.get_lives() if player and player.has_method("get_lives") else 0
	if player_lives <= 0:
		_fail("Player did not respawn (lives: %s)" % player_lives)
		return
	print("Player respawned with %s lives" % player_lives)

	# Check 3: Boss should still exist
	var current_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else main.get_node_or_null("Boss")
	if not current_boss or not is_instance_valid(current_boss):
		_fail("Boss no longer exists after player respawn")
		return

	# Check 4: Boss should have full health again
	var boss_health = current_boss.health if "health" in current_boss else 0
	var boss_max_health = current_boss._max_health if "_max_health" in current_boss else 13
	print("Boss health after respawn: %s/%s" % [boss_health, boss_max_health])
	if boss_health != boss_max_health:
		_fail("Boss health not reset to full. Current: %s, Max: %s" % [boss_health, boss_max_health])
		return
	print("Boss health reset to full: %s/%s" % [boss_health, boss_max_health])

	_pass()


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
			_fail("Test timed out - respawn not verified")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Player respawns at boss entrance instead of game over.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
