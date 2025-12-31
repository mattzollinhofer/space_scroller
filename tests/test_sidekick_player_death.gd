extends Node2D
## Integration test: Sidekick destroyed on player death
## Verifies that the sidekick is destroyed when the player dies.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0  # Increased timeout for invincibility waits
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null


func _ready() -> void:
	print("=== Test: Sidekick Destroyed on Player Death ===")

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
	await _run_player_death_test()


func _run_player_death_test() -> void:
	# Move player to a known position
	_player.position = Vector2(400, 768)
	await get_tree().process_frame

	# Spawn and collect sidekick pickup
	var pickup_scene = load("res://scenes/pickups/sidekick_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load sidekick_pickup scene")
		return

	var pickup = pickup_scene.instantiate()
	pickup.position = _player.position
	pickup.setup(pickup.SpawnEdge.LEFT)

	_main.add_child(pickup)
	print("Sidekick pickup spawned at player position")

	# Wait for collection
	await get_tree().create_timer(0.2).timeout

	# Verify sidekick spawned
	var sidekick = _get_sidekick()
	if not sidekick:
		_fail("Sidekick was not spawned after collecting pickup")
		return

	print("Sidekick spawned successfully")

	# Count sidekicks before player death
	var sidekick_count_before = _count_sidekicks()
	print("Sidekick count before player death: %d" % sidekick_count_before)

	if sidekick_count_before != 1:
		_fail("Expected 1 sidekick, got %d" % sidekick_count_before)
		return

	# Kill the player by removing all lives and dealing damage
	# Player starts with 3 lives, need to deal damage 3 times
	# Player has 1.5 second invincibility after each hit
	var starting_lives = _player.get_lives()
	print("Player starting lives: %d" % starting_lives)

	# Deal damage until player dies
	while _player.get_lives() > 0:
		var lives_before = _player.get_lives()
		_player.take_damage()
		var lives_after = _player.get_lives()
		print("Dealt damage - lives before: %d, after: %d" % [lives_before, lives_after])

		if lives_after <= 0:
			print("Player died!")
			break

		# Wait for invincibility to end (1.5 seconds + small buffer)
		await get_tree().create_timer(1.6).timeout

	# Wait for death processing and sidekick destruction animation (0.3s) + buffer
	await get_tree().create_timer(0.5).timeout

	# Count sidekicks after player death (only count valid sidekicks not being destroyed)
	var sidekick_count_after = 0
	for s in get_tree().get_nodes_in_group("sidekick"):
		if is_instance_valid(s) and not s.get("_is_destroying"):
			sidekick_count_after += 1

	print("Sidekick count after player death: %d" % sidekick_count_after)

	# Also check if any sidekick still exists in the tree
	var remaining_sidekicks = get_tree().get_nodes_in_group("sidekick")
	print("Total sidekicks in group: %d" % remaining_sidekicks.size())
	for s in remaining_sidekicks:
		print("  - Valid: %s, Destroying: %s" % [is_instance_valid(s), s.get("_is_destroying")])

	if sidekick_count_after != 0:
		_fail("Expected sidekick to be destroyed after player death, but found %d sidekick(s)" % sidekick_count_after)
		return

	print("Sidekick destroyed on player death!")
	_pass()


func _get_sidekick() -> Node:
	var sidekicks = get_tree().get_nodes_in_group("sidekick")
	if sidekicks.size() > 0:
		return sidekicks[0]
	return null


func _count_sidekicks() -> int:
	return get_tree().get_nodes_in_group("sidekick").size()


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
	print("Sidekick is destroyed when player dies.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
