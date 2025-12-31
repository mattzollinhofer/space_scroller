extends Node2D
## Integration test: Kill 5 enemies, random pickup spawns
## Verifies that killing 5 enemies spawns either a star or sidekick pickup,
## and that the kill counter resets with threshold doubling.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _enemy_spawner: Node = null
var _pickup_spawned: bool = false
var _spawned_pickup_type: String = ""


func _ready() -> void:
	print("=== Test: Kill 5 Enemies Spawns Random Pickup ===")

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

	# Find the enemy spawner
	_enemy_spawner = _main.get_node_or_null("EnemySpawner")
	if not _enemy_spawner:
		_fail("EnemySpawner node not found in main scene")
		return

	# Disable continuous spawning to have a clean test
	_enemy_spawner.set_continuous_spawning(false)
	_enemy_spawner.clear_all()
	_enemy_spawner.reset()

	# Wait another frame for things to settle
	await get_tree().process_frame

	# Run the test
	await _run_random_pickup_test()


func _run_random_pickup_test() -> void:
	# Move player to a known position away from enemies
	_player.position = Vector2(200, 768)
	await get_tree().process_frame

	# Get initial threshold (should be 5)
	var initial_threshold = _enemy_spawner._next_pickup_threshold
	print("Initial pickup threshold: %d" % initial_threshold)

	if initial_threshold != 5:
		_fail("Expected initial threshold to be 5, got %d" % initial_threshold)
		return

	# Spawn and kill 5 enemies
	for i in range(5):
		await _spawn_and_kill_enemy(i + 1)
		await get_tree().process_frame

	# Wait for pickup to spawn
	await get_tree().create_timer(0.2).timeout

	# Check if a pickup was spawned
	var pickup = _find_pickup_in_scene()
	if not pickup:
		_fail("No pickup was spawned after killing 5 enemies")
		return

	print("Pickup spawned: %s" % _get_pickup_type(pickup))

	# Determine pickup type
	var pickup_type = _get_pickup_type(pickup)
	if pickup_type == "StarPickup":
		_spawned_pickup_type = "star"
		print("Spawned pickup type: Star Pickup")
	elif pickup_type == "SidekickPickup":
		_spawned_pickup_type = "sidekick"
		print("Spawned pickup type: Sidekick Pickup")
	else:
		_fail("Unknown pickup type spawned: %s" % pickup_type)
		return

	# Verify kill counter was reset
	var kill_count_after = _enemy_spawner._kill_count
	print("Kill count after pickup spawn: %d" % kill_count_after)

	if kill_count_after != 0:
		_fail("Expected kill count to reset to 0, got %d" % kill_count_after)
		return

	# Verify threshold was doubled
	var new_threshold = _enemy_spawner._next_pickup_threshold
	print("New pickup threshold: %d" % new_threshold)

	if new_threshold != 10:
		_fail("Expected threshold to double to 10, got %d" % new_threshold)
		return

	print("Random pickup spawn test passed!")
	_pass()


func _spawn_and_kill_enemy(enemy_number: int) -> void:
	print("Spawning and killing enemy %d..." % enemy_number)

	# Spawn an enemy
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load stationary enemy scene")
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(800, 768)

	# Add to enemy spawner so it gets tracked properly
	_enemy_spawner.add_child(enemy)

	# Connect the died signal to spawner's kill handler
	if enemy.has_signal("died"):
		enemy.died.connect(_enemy_spawner._on_enemy_killed.bind(enemy))

	await get_tree().process_frame

	# Kill the enemy by calling take_hit with damage (stationary enemies have 1 health)
	if enemy.has_method("take_hit"):
		enemy.take_hit(1)  # Pass damage amount
		await get_tree().process_frame


func _find_pickup_in_scene() -> Node:
	# Look for star pickup or sidekick pickup in Main scene
	for child in _main.get_children():
		var pickup_type = _get_pickup_type(child)
		if pickup_type == "StarPickup" or pickup_type == "SidekickPickup":
			return child
	return null


func _get_pickup_type(node: Node) -> String:
	# Get the class name from the script
	var script = node.get_script()
	if script:
		var script_path = script.resource_path
		if "star_pickup" in script_path:
			return "StarPickup"
		elif "sidekick_pickup" in script_path:
			return "SidekickPickup"
	return node.get_class()


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
	print("Random pickup spawns correctly after 5 enemy kills with threshold doubling.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
