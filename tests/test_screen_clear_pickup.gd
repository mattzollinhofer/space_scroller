extends Node2D
## Test: Screen clear pickup destroys all enemies on screen

var _test_passed: bool = false


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

	# Wait for collection and enemy destruction (enemies take time to die)
	await get_tree().create_timer(0.5).timeout

	# Count enemies after pickup (filter out destroyed ones)
	var enemies_after = 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			enemies_after += 1
	print("Enemies after pickup: %d" % enemies_after)

	if enemies_after >= enemies_before:
		_fail("Expected enemies to be destroyed, but count is still %d" % enemies_after)
		return

	print("Enemies destroyed by screen clear - OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Screen clear pickup destroys enemies on screen.")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED: %s ===" % reason)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(1)
