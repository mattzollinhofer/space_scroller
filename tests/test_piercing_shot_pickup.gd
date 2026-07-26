extends Node2D
## Test: Piercing shot pickup grants temporary piercing projectiles

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _test_timeout: float = 8.0
var _timer: float = 0.0


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

	# Poll until the pickup is collected and piercing activates
	await TestHelpers.poll_until(get_tree(), func(): return player.is_piercing_shots_active(), 3.0)

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

	if not found_piercing_projectile:
		_fail("No piercing projectile found after shooting with piercing active")
		return

	print("Piercing projectile check complete - OK")

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Piercing shot pickup grants temporary piercing projectiles.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED: %s ===" % reason)
	get_tree().quit(1)
