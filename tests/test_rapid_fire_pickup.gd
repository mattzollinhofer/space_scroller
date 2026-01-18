extends Node2D
## Test: Rapid fire pickup grants temporary fast firing

var _test_passed: bool = false


func _ready() -> void:
	print("=== Test: Rapid Fire Pickup ===")
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

	# Verify player doesn't have rapid fire initially
	if player.is_rapid_fire_active():
		_fail("Player should not have rapid fire initially")
		return

	print("Player starts without rapid fire - OK")

	# Load and spawn rapid fire pickup
	var pickup_scene = load("res://scenes/pickups/rapid_fire_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load rapid fire pickup scene")
		return

	var pickup = pickup_scene.instantiate()
	pickup.position = player.position
	pickup.setup(pickup.SpawnEdge.LEFT)
	add_child(pickup)
	await get_tree().process_frame

	print("Rapid fire pickup spawned - OK")

	# Wait for collection
	await get_tree().create_timer(0.2).timeout

	# Verify player now has rapid fire
	if not player.is_rapid_fire_active():
		_fail("Player should have rapid fire after collecting pickup")
		return

	print("Player has rapid fire after collection - OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Rapid fire pickup grants temporary fast firing.")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED: %s ===" % reason)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(1)
