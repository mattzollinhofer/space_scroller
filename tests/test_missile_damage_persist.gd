extends Node2D
## Integration test: Damage boost persists between levels
## Verifies that when player completes a level with a damage boost, they start the next level with that same boost.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0


func _ready() -> void:
	print("=== Test: Damage Boost Persists Between Levels ===")

	# Run the test
	await _run_persistence_test()


func _run_persistence_test() -> void:
	# Get GameState autoload
	var game_state = get_node_or_null("/root/GameState")
	if not game_state:
		_fail("GameState autoload not found")
		return

	# First verify set_damage_boost method exists
	if not game_state.has_method("set_damage_boost"):
		_fail("GameState does not have set_damage_boost() method")
		return

	# Clear any existing damage boost
	if game_state.has_method("clear_damage_boost"):
		game_state.clear_damage_boost()

	# Set damage boost to 2 (simulating completing level with boost)
	game_state.set_damage_boost(2)
	print("Set GameState damage boost to 2")

	# Verify it was stored
	if not game_state.has_method("get_damage_boost"):
		_fail("GameState does not have get_damage_boost() method")
		return

	var stored_boost = game_state.get_damage_boost()
	if stored_boost != 2:
		_fail("GameState.get_damage_boost() should return 2, got %d" % stored_boost)
		return

	print("GameState.get_damage_boost() returns: %d" % stored_boost)

	# Now load a new main scene (simulating starting a new level)
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Wait for scene to initialize (player reads from GameState in _ready)
	await get_tree().process_frame
	await get_tree().process_frame

	# Find the player
	var player = main.get_node_or_null("Player")
	if not player:
		_fail("Player node not found in main scene")
		return

	# Disable enemy spawning to have a clean test
	var enemy_spawner = main.get_node_or_null("EnemySpawner")
	if enemy_spawner:
		enemy_spawner.set_continuous_spawning(false)
		enemy_spawner.clear_all()

	# Verify player has the damage boost from GameState
	if not player.has_method("get_damage_boost"):
		_fail("Player does not have get_damage_boost() method")
		return

	var player_boost = player.get_damage_boost()
	print("Player damage boost after level load: %d" % player_boost)

	if player_boost != 2:
		_fail("Player should have damage boost of 2 from GameState, got %d" % player_boost)
		return

	# Wait a frame for UI to update
	await get_tree().process_frame

	# Verify DamageBoostDisplay shows "x3" (base 1 + 2 boost = 3)
	var damage_display = main.get_node_or_null("DamageBoostDisplay")
	if not damage_display:
		_fail("DamageBoostDisplay node not found in main scene")
		return

	if not damage_display.visible:
		_fail("DamageBoostDisplay should be visible when damage boost is 2")
		return

	var label = damage_display.get_node_or_null("Container/Label")
	if not label:
		_fail("Label node not found in DamageBoostDisplay")
		return

	var expected_text = "x3"
	if label.text != expected_text:
		_fail("Expected DamageBoostDisplay label to show '%s', got '%s'" % [expected_text, label.text])
		return

	print("DamageBoostDisplay shows: %s" % label.text)

	# Clean up - clear boost from GameState
	game_state.clear_damage_boost()
	print("Cleared GameState damage boost")

	# Verify clear works
	var cleared_boost = game_state.get_damage_boost()
	if cleared_boost != 0:
		_fail("GameState.clear_damage_boost() should set boost to 0, got %d" % cleared_boost)
		return

	print("GameState damage boost cleared successfully")
	print("Damage boost persistence between levels works correctly!")
	_pass()


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
	print("Damage boost persists between levels - player starts new level with saved boost.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
