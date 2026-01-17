extends Node2D
## Integration test: Collecting sidekick when one already active
## Verifies that only one sidekick can be active at a time.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _pickup_collected_count: int = 0


func _ready() -> void:
	print("=== Test: Only One Sidekick Active at a Time ===")

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
	await _run_duplicate_sidekick_test()


func _run_duplicate_sidekick_test() -> void:
	# Move player to a known position
	_player.position = Vector2(400, 768)
	await get_tree().process_frame

	# Spawn and collect first sidekick pickup
	var pickup_scene = load("res://scenes/pickups/sidekick_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load sidekick_pickup scene")
		return

	var first_pickup = pickup_scene.instantiate()
	first_pickup.position = _player.position
	first_pickup.setup(first_pickup.SpawnEdge.LEFT)
	first_pickup.collected.connect(_on_pickup_collected)

	_main.add_child(first_pickup)
	print("First sidekick pickup spawned at player position")

	# Wait for collection
	await get_tree().create_timer(0.2).timeout

	# Verify first sidekick spawned
	var first_sidekick = _main.get_node_or_null("Sidekick")
	if not first_sidekick:
		_fail("First sidekick was not spawned after collecting pickup")
		return

	print("First sidekick spawned successfully: %s" % first_sidekick.name)

	# Count sidekicks
	var sidekick_count_before = _count_sidekicks()
	print("Sidekick count before second pickup: %d" % sidekick_count_before)

	if sidekick_count_before != 1:
		_fail("Expected 1 sidekick, got %d" % sidekick_count_before)
		return

	# Spawn and collect second sidekick pickup
	var second_pickup = pickup_scene.instantiate()
	second_pickup.position = _player.position
	second_pickup.setup(second_pickup.SpawnEdge.LEFT)
	second_pickup.collected.connect(_on_pickup_collected)

	_main.add_child(second_pickup)
	print("Second sidekick pickup spawned at player position")

	# Wait for collection
	await get_tree().create_timer(0.2).timeout

	# Verify still only one sidekick
	var sidekick_count_after = _count_sidekicks()
	print("Sidekick count after second pickup: %d" % sidekick_count_after)

	if sidekick_count_after != 1:
		_fail("Expected still 1 sidekick, got %d - duplicate sidekick was created!" % sidekick_count_after)
		return

	# Verify pickup was still collected (signal emitted)
	print("Pickup collected count: %d" % _pickup_collected_count)

	if _pickup_collected_count != 2:
		_fail("Expected 2 pickups collected signals, got %d" % _pickup_collected_count)
		return

	print("Only one sidekick active at a time - new pickup replaces old sidekick!")
	_pass()


func _on_pickup_collected() -> void:
	_pickup_collected_count += 1
	print("Sidekick pickup collected signal received (count: %d)" % _pickup_collected_count)


func _count_sidekicks() -> int:
	var count = 0
	for child in _main.get_children():
		if child.is_in_group("sidekick"):
			count += 1
	return count


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
	print("Only one sidekick can be active at a time.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
