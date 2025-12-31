extends Node2D
## Integration test: Sidekick has no invincibility - single hit destruction
## Verifies that sidekick is destroyed on first enemy hit (no health system, no grace period).

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _pickup_collected: bool = false


func _ready() -> void:
	print("=== Test: Sidekick No Invincibility (Single Hit Destruction) ===")

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
	await _run_single_hit_destruction_test()


func _run_single_hit_destruction_test() -> void:
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

	# Wait for collision detection and collection
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# Check if pickup was collected
	if not _pickup_collected:
		_fail("Sidekick Pickup was not collected")
		return

	print("Sidekick collected!")

	# Find the sidekick
	var sidekick = _find_sidekick()
	if not sidekick:
		_fail("Sidekick was not spawned after collecting pickup")
		return

	# Verify sidekick does NOT have a health property (no health system)
	if sidekick.get("health") != null:
		_fail("Sidekick has a health property - should be single hit destruction, no health system")
		return
	print("Confirmed: Sidekick has no health property (single hit kill)")

	# Wait for sidekick to settle
	await get_tree().create_timer(0.2).timeout
	var sidekick_pos = sidekick.position
	print("Sidekick at position: %s" % str(sidekick_pos))

	# Spawn an enemy at the sidekick's position
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load stationary_enemy scene")
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = sidekick_pos
	enemy.scroll_speed = 0.0
	enemy.zigzag_speed = 0.0
	_main.add_child(enemy)
	print("Enemy spawned at sidekick position for collision")

	# Wait for physics collision to occur
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# After a single collision, sidekick should be in destruction state or gone
	if sidekick and is_instance_valid(sidekick):
		if sidekick.get("_is_destroying") == true:
			print("Sidekick is being destroyed after single enemy contact")
		else:
			# Sidekick still exists and not being destroyed - this is a failure
			_fail("Sidekick survived enemy contact - expected immediate destruction on first hit")
			return
	else:
		print("Sidekick already removed (immediate queue_free)")

	# Wait for destruction animation to complete
	await get_tree().create_timer(0.5).timeout

	# Verify sidekick is fully removed
	var sidekick_after = _find_sidekick()
	if sidekick_after and is_instance_valid(sidekick_after):
		_fail("Sidekick still exists after destruction - should have been fully removed")
		return

	print("Confirmed: Sidekick destroyed on first enemy hit (no invincibility)")
	_pass()


func _find_sidekick() -> Node:
	if not is_instance_valid(_main):
		return null

	var sidekick = _main.get_node_or_null("Sidekick")
	if sidekick and is_instance_valid(sidekick):
		return sidekick

	for child in _main.get_children():
		if not is_instance_valid(child):
			continue
		if child.is_in_group("sidekick"):
			return child

	return null


func _on_pickup_collected() -> void:
	_pickup_collected = true


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
	print("Sidekick has no invincibility - destroyed on first enemy contact.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
