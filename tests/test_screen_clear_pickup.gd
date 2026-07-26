extends Node2D
## Test: Screen clear pickup destroys all enemies on screen

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _test_timeout: float = 8.0
var _timer: float = 0.0


func _ready() -> void:
	print("=== Test: Screen Clear Pickup ===")
	await get_tree().process_frame
	await _run_test()


func _run_test() -> void:
	# Load player scene
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return

	var player = player_scene.instantiate()
	player.position = Vector2(400, 400)
	add_child(player)
	await get_tree().process_frame

	# Spawn some enemies
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load enemy scene")
		return

	for i in range(3):
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(600 + i * 100, 400)
		add_child(enemy)

	await get_tree().process_frame

	# Count enemies before pickup
	var enemies_before = get_tree().get_nodes_in_group("enemy").size()
	print("Enemies before pickup: %d" % enemies_before)

	if enemies_before < 3:
		_fail("Expected at least 3 enemies, got %d" % enemies_before)
		return

	# Load and spawn screen clear pickup
	var pickup_scene = load("res://scenes/pickups/screen_clear_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load screen clear pickup scene")
		return

	var pickup = pickup_scene.instantiate()
	pickup.position = player.position
	pickup.setup(pickup.SpawnEdge.LEFT)
	add_child(pickup)
	await get_tree().process_frame

	print("Screen clear pickup spawned - OK")

	# Poll until collection destroys enemies rather than guessing a settle time
	await TestHelpers.poll_until(get_tree(), func(): return _count_live_enemies() < enemies_before, 3.0)

	# Count enemies after pickup (filter out destroyed ones)
	var enemies_after = _count_live_enemies()
	print("Enemies after pickup: %d" % enemies_after)

	if enemies_after >= enemies_before:
		_fail("Expected enemies to be destroyed, but count is still %d" % enemies_after)
		return

	print("Enemies destroyed by screen clear - OK")

	_pass()


func _count_live_enemies() -> int:
	var count = 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			count += 1
	return count


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Screen clear pickup destroys enemies on screen.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED: %s ===" % reason)
	get_tree().quit(1)
