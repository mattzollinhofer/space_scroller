extends Node2D
## Integration test: Sidekick fires when player fires
## Verifies that when player shoots, sidekick simultaneously fires its own projectile.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _pickup_collected: bool = false


func _ready() -> void:
	print("=== Test: Sidekick Fires When Player Fires ===")

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
	await _run_sidekick_shooting_test()


func _run_sidekick_shooting_test() -> void:
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

	# Wait for sidekick to settle
	await get_tree().create_timer(0.2).timeout

	# Count existing projectiles before player shoots
	var projectiles_before = _count_projectiles()
	print("Projectiles before shooting: %d" % projectiles_before)

	# Trigger player to shoot
	print("Triggering player shoot...")
	_player.shoot(true)

	# Wait a frame for projectiles to spawn
	await get_tree().process_frame
	await get_tree().process_frame

	# Count projectiles after shooting
	var projectiles_after = _count_projectiles()
	print("Projectiles after shooting: %d" % projectiles_after)

	# Calculate how many projectiles were spawned
	var projectiles_spawned = projectiles_after - projectiles_before
	print("Projectiles spawned: %d" % projectiles_spawned)

	# Verify two projectiles were spawned (player + sidekick)
	if projectiles_spawned < 2:
		_fail("Expected 2 projectiles (player + sidekick), but only %d were spawned" % projectiles_spawned)
		return

	# Verify projectiles are at different positions (player vs sidekick)
	var projectiles = _get_projectiles()
	if projectiles.size() >= 2:
		var pos1 = projectiles[0].position
		var pos2 = projectiles[1].position
		print("Projectile 1 position: %s" % str(pos1))
		print("Projectile 2 position: %s" % str(pos2))

		# Projectiles should be at different Y positions (sidekick offset)
		if abs(pos1.y - pos2.y) < 1.0 and abs(pos1.x - pos2.x) < 1.0:
			print("Warning: Projectiles are at same position, expected different positions")

	print("Sidekick successfully fires when player fires!")
	_pass()


func _find_sidekick() -> Node:
	var sidekick = _main.get_node_or_null("Sidekick")
	if sidekick:
		return sidekick

	# Also check if it was added with a different name pattern
	for child in _main.get_children():
		if child.is_in_group("sidekick") or child.get_class() == "Sidekick" or (child.has_method("get_script") and child.get_script() and "Sidekick" in str(child.get_script().resource_path)):
			return child

	return null


func _count_projectiles() -> int:
	var count = 0
	for child in _main.get_children():
		if "Projectile" in child.name or (child.has_method("get_script") and child.get_script() and "projectile" in str(child.get_script().resource_path).to_lower()):
			count += 1
	return count


func _get_projectiles() -> Array:
	var projectiles = []
	for child in _main.get_children():
		if "Projectile" in child.name or (child.has_method("get_script") and child.get_script() and "projectile" in str(child.get_script().resource_path).to_lower()):
			projectiles.append(child)
	return projectiles


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
	print("Sidekick shooting works - fires projectile when player fires.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
