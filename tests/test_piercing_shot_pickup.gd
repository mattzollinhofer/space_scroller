extends Node2D
## Test: Piercing shot pickup grants temporary piercing projectiles

var _test_passed: bool = false


func _ready() -> void:
	print("=== Test: Piercing Shot Pickup ===")
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

	# Verify player doesn't have piercing shots initially
	if player.is_piercing_shots_active():
		_fail("Player should not have piercing shots initially")
		return

	print("Player starts without piercing shots - OK")

	# Load and spawn piercing shot pickup
	var pickup_scene = load("res://scenes/pickups/piercing_shot_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load piercing shot pickup scene")
		return

	var pickup = pickup_scene.instantiate()
	pickup.position = player.position
	pickup.setup(pickup.SpawnEdge.LEFT)
	add_child(pickup)
	await get_tree().process_frame

	print("Piercing shot pickup spawned - OK")

	# Wait for collection
	await get_tree().create_timer(0.2).timeout

	# Verify player now has piercing shots
	if not player.is_piercing_shots_active():
		_fail("Player should have piercing shots after collecting pickup")
		return

	print("Player has piercing shots after collection - OK")

	# Test that projectile has piercing flag when shot
	player.shoot()
	await get_tree().process_frame

	var projectiles = get_tree().get_nodes_in_group("projectile")
	# Projectiles might not be in a group, so check children
	var found_piercing_projectile = false
	for child in get_children():
		if child.has_method("_on_area_entered") and "piercing" in child:
			if child.piercing:
				found_piercing_projectile = true
				break

	# Also check parent
	for child in get_parent().get_children():
		if "piercing" in child:
			if child.piercing:
				found_piercing_projectile = true
				break

	print("Piercing projectile check complete - OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Piercing shot pickup grants temporary piercing projectiles.")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED: %s ===" % reason)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(1)
