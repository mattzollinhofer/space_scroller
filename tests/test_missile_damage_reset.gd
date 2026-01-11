extends Node2D
## Integration test: Damage boost resets on life loss
## Verifies that when player loses all health and uses a life, damage boost resets to zero.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _life_lost_signal_received: bool = false


func _ready() -> void:
	print("=== Test: Damage Boost Resets on Life Loss ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	_main = main_scene.instantiate()
	add_child(_main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find the player
	_player = _main.get_node_or_null("Player")
	if not _player:
		_fail("Player node not found in main scene")
		return

	# Disable enemy spawning to have a clean test
	var enemy_spawner = _main.get_node_or_null("EnemySpawner")
	if enemy_spawner:
		enemy_spawner.set_continuous_spawning(false)
		enemy_spawner.clear_all()

	# Wait another frame for things to settle
	await get_tree().process_frame

	# Run the test
	await _run_damage_reset_test()


func _run_damage_reset_test() -> void:
	# Move player to a known position
	_player.position = Vector2(400, 768)
	await get_tree().process_frame

	# Setup player with 2 lives and 2 damage boost
	# First, ensure player has at least 2 lives
	if _player.get_lives() < 2:
		# Give extra lives via gain_life or direct setting
		_player._lives = 2
		_player.lives_changed.emit(_player._lives)

	print("Player lives: %d" % _player.get_lives())

	if _player.get_lives() < 2:
		_fail("Could not set player to have 2 lives")
		return

	# Give 2 damage boost
	_player.add_damage_boost()
	_player.add_damage_boost()
	var initial_boost = _player.get_damage_boost()
	print("Initial damage boost: %d (expected 2)" % initial_boost)

	if initial_boost != 2:
		_fail("Expected damage boost of 2, got %d" % initial_boost)
		return

	# Verify DamageBoostDisplay is visible
	var damage_display = _main.get_node_or_null("DamageBoostDisplay")
	if not damage_display:
		_fail("DamageBoostDisplay node not found")
		return

	# Wait a frame for display to update
	await get_tree().process_frame

	if not damage_display.visible:
		_fail("DamageBoostDisplay should be visible when damage boost is 2")
		return

	print("DamageBoostDisplay is visible before life loss")

	# Connect to life_lost signal
	_player.life_lost.connect(_on_life_lost)

	# Damage player until life is lost (health depletes)
	var starting_lives = _player.get_lives()
	print("Starting lives: %d, health: %d" % [starting_lives, _player.get_health()])

	# Take damage until health reaches 0 (triggers life_lost)
	while _player.get_health() > 0 and not _life_lost_signal_received:
		_player.take_damage()
		await get_tree().process_frame

	# Wait a moment for signals to propagate
	await get_tree().process_frame
	await get_tree().process_frame

	# Verify life was lost
	if not _life_lost_signal_received:
		_fail("life_lost signal was not emitted")
		return

	print("life_lost signal received")

	# Verify lives decreased
	var current_lives = _player.get_lives()
	if current_lives >= starting_lives:
		_fail("Lives did not decrease after life_lost. Started with %d, now have %d" % [starting_lives, current_lives])
		return

	print("Lives decreased from %d to %d" % [starting_lives, current_lives])

	# Verify damage boost is now 0
	var new_boost = _player.get_damage_boost()
	print("Damage boost after life loss: %d" % new_boost)

	if new_boost != 0:
		_fail("Expected damage boost to reset to 0 after life loss, got %d" % new_boost)
		return

	# Wait a frame for display update
	await get_tree().process_frame

	# Verify DamageBoostDisplay is hidden
	if damage_display.visible:
		_fail("DamageBoostDisplay should be hidden when damage boost is 0")
		return

	print("DamageBoostDisplay is hidden after life loss")

	# Verify GameState.get_damage_boost() returns 0 (if implemented)
	var game_state = get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("get_damage_boost"):
		var gs_boost = game_state.get_damage_boost()
		if gs_boost != 0:
			_fail("GameState.get_damage_boost() should be 0, got %d" % gs_boost)
			return
		print("GameState.get_damage_boost() is 0")
	else:
		print("Note: GameState.get_damage_boost() not yet implemented (expected for Slice 3)")

	# Verify player can collect new pickups after reset (collect one more)
	print("Testing that player can collect new pickups after reset...")
	_player.add_damage_boost()
	var boost_after_collect = _player.get_damage_boost()

	if boost_after_collect != 1:
		_fail("Player should be able to collect new pickups after reset. Expected 1, got %d" % boost_after_collect)
		return

	print("Player can collect new pickups after reset (boost now: %d)" % boost_after_collect)

	print("Damage boost reset on life loss works correctly!")
	_pass()


func _on_life_lost() -> void:
	_life_lost_signal_received = true
	print("life_lost signal received!")


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
	print("Damage boost resets on life loss - UI hides and player can collect new pickups.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
