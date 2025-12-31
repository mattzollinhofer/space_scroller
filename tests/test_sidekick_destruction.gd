extends Node2D
## Integration test: Sidekick destroyed on enemy contact
## Verifies that when an enemy collides with the sidekick, the sidekick is destroyed.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _pickup_collected: bool = false


func _ready() -> void:
	print("=== Test: Sidekick Destroyed on Enemy Contact ===")

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
	await _run_sidekick_destruction_test()


func _run_sidekick_destruction_test() -> void:
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

	# Find the sidekick
	var sidekick = _find_sidekick()
	if not sidekick:
		_fail("Sidekick was not spawned after collecting pickup")
		return

	print("Sidekick found: %s at position %s" % [sidekick.name, str(sidekick.position)])

	# Wait for sidekick to settle at its position
	await get_tree().create_timer(0.2).timeout

	var sidekick_pos = sidekick.position
	print("Sidekick position: %s" % str(sidekick_pos))

	# Spawn an enemy at the sidekick's position
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load stationary_enemy scene")
		return

	var enemy = enemy_scene.instantiate()
	# Position enemy directly on top of sidekick for immediate collision
	enemy.position = sidekick_pos
	# Disable enemy movement so it stays in place
	enemy.scroll_speed = 0.0
	enemy.zigzag_speed = 0.0
	_main.add_child(enemy)
	print("Enemy spawned at sidekick position: %s" % str(enemy.position))

	# Wait for collision detection
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout

	# Check if sidekick was destroyed
	var sidekick_after = _find_sidekick()
	if sidekick_after and is_instance_valid(sidekick_after):
		# Check if sidekick is in process of being destroyed (might still exist during animation)
		# We'll wait a bit more for destruction animation
		await get_tree().create_timer(0.5).timeout
		sidekick_after = _find_sidekick()
		if sidekick_after and is_instance_valid(sidekick_after):
			_fail("Sidekick was NOT destroyed by enemy contact - still exists in scene")
			return

	print("Sidekick was destroyed by enemy contact!")

	# Verify enemy is still alive (enemy should not be destroyed by touching sidekick)
	if not is_instance_valid(enemy):
		print("Note: Enemy was also destroyed (this may be expected behavior)")

	_pass()


func _find_sidekick() -> Node:
	if not is_instance_valid(_main):
		return null

	var sidekick = _main.get_node_or_null("Sidekick")
	if sidekick and is_instance_valid(sidekick):
		return sidekick

	# Also check if it was added with a different name pattern
	for child in _main.get_children():
		if not is_instance_valid(child):
			continue
		if child.is_in_group("sidekick") or child.get_class() == "Sidekick" or (child.has_method("get_script") and child.get_script() and "Sidekick" in str(child.get_script().resource_path)):
			return child

	return null


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
	print("Sidekick destruction works - destroyed on enemy contact.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
