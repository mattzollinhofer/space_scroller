extends Node2D
## Test: Triple shot pickup grants temporary 3-projectile attack

var _test_passed: bool = false


func _ready() -> void:
	print("=== Test: Triple Shot Pickup ===")
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

	# Verify player doesn't have triple shot initially
	if player.is_triple_shot_active():
		_fail("Player should not have triple shot initially")
		return

	print("Player starts without triple shot - OK")

	# Load and spawn triple shot pickup
	var pickup_scene = load("res://scenes/pickups/triple_shot_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load triple shot pickup scene")
		return

	var pickup = pickup_scene.instantiate()
	pickup.position = player.position
	pickup.setup(pickup.SpawnEdge.LEFT)
	add_child(pickup)
	await get_tree().process_frame

	print("Triple shot pickup spawned - OK")

	# Wait for collection
	await get_tree().create_timer(0.2).timeout

	# Verify player now has triple shot
	if not player.is_triple_shot_active():
		_fail("Player should have triple shot after collecting pickup")
		return

	print("Player has triple shot after collection - OK")

	# Test that 3 projectiles are spawned when shooting
	var projectile_count_before = _count_projectiles()
	player.shoot()
	await get_tree().process_frame

	var projectile_count_after = _count_projectiles()
	var projectiles_spawned = projectile_count_after - projectile_count_before

	print("Projectiles spawned: %d" % projectiles_spawned)

	if projectiles_spawned != 3:
		_fail("Expected 3 projectiles, got %d" % projectiles_spawned)
		return

	print("Triple shot spawns 3 projectiles - OK")

	_pass()


func _count_projectiles() -> int:
	var count = 0
	for child in get_parent().get_children():
		if child.has_method("_on_area_entered") and "damage" in child:
			count += 1
	for child in get_children():
		if child.has_method("_on_area_entered") and "damage" in child:
			count += 1
	return count


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Triple shot pickup grants temporary 3-projectile attack.")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED: %s ===" % reason)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(1)
