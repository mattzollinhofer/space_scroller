extends Node2D
## Integration test: Player collects sidekick_pickup and sidekick follows player
## Verifies that collecting a SidekickPickup spawns a sidekick that follows the player.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _pickup_collected: bool = false


func _ready() -> void:
	print("=== Test: Player Collects Sidekick Pickup and Sidekick Follows ===")

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
	await _run_sidekick_pickup_test()


func _run_sidekick_pickup_test() -> void:
	# Move player to a known position
	_player.position = Vector2(400, 768)
	await get_tree().process_frame

	# Spawn a Sidekick Pickup at player's exact position for immediate collision
	var pickup_scene = load("res://scenes/pickups/sidekick_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load sidekick_pickup scene")
		return

	var sidekick_pickup = pickup_scene.instantiate()
	sidekick_pickup.position = _player.position
	sidekick_pickup.setup(sidekick_pickup.SpawnEdge.LEFT)

	# Connect to the collected signal
	sidekick_pickup.collected.connect(_on_pickup_collected)

	_main.add_child(sidekick_pickup)
	print("Sidekick Pickup spawned at player position: %s" % str(sidekick_pickup.position))

	# Wait for collision detection and collection
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# Check if pickup was collected
	if not _pickup_collected:
		_fail("Sidekick Pickup was not collected (collected signal not emitted)")
		return

	print("Sidekick pickup collected!")

	# Check if a sidekick was spawned
	var sidekick = _main.get_node_or_null("Sidekick")
	if not sidekick:
		# Also check if it was added with a different name pattern
		for child in _main.get_children():
			if child.is_in_group("sidekick") or child.get_class() == "Sidekick" or (child.has_method("get_script") and child.get_script() and "Sidekick" in str(child.get_script().resource_path)):
				sidekick = child
				break

	if not sidekick:
		_fail("Sidekick was not spawned after collecting pickup")
		return

	print("Sidekick spawned: %s at position %s" % [sidekick.name, str(sidekick.position)])

	# Verify sidekick starts near player (with offset)
	var initial_offset = sidekick.position - _player.position
	print("Initial sidekick offset from player: %s" % str(initial_offset))

	# Move player to a new position
	var new_player_pos = Vector2(600, 500)
	_player.position = new_player_pos
	print("Player moved to: %s" % str(new_player_pos))

	# Wait for sidekick to follow (give it time to lerp)
	await get_tree().create_timer(0.5).timeout

	# Verify sidekick followed (should be moving toward player)
	var sidekick_pos = sidekick.position
	print("Sidekick position after player move: %s" % str(sidekick_pos))

	# Calculate distance to expected position (player + offset)
	# Sidekick should be behind and slightly offset from player
	var expected_offset = Vector2(-50, -30)  # Behind and above player
	var expected_pos = new_player_pos + expected_offset
	var distance_to_expected = sidekick_pos.distance_to(expected_pos)

	# Allow some tolerance since we're using lerp
	if distance_to_expected > 200:
		_fail("Sidekick did not follow player. Expected near %s, got %s (distance: %.1f)" % [str(expected_pos), str(sidekick_pos), distance_to_expected])
		return

	# Move player again and verify sidekick keeps following
	new_player_pos = Vector2(300, 900)
	_player.position = new_player_pos
	print("Player moved to: %s" % str(new_player_pos))

	await get_tree().create_timer(0.5).timeout

	var sidekick_pos_after = sidekick.position
	print("Sidekick position after second move: %s" % str(sidekick_pos_after))

	# Sidekick should have moved toward the new player position
	if sidekick_pos_after.distance_to(sidekick_pos) < 50:
		_fail("Sidekick did not follow player's second movement")
		return

	print("Sidekick successfully follows player!")
	_pass()


func _on_pickup_collected() -> void:
	_pickup_collected = true
	print("Sidekick pickup collected signal received!")


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
	print("Sidekick pickup collection works - spawns sidekick that follows player.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
