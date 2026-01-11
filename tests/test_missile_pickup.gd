extends Node2D
## Integration test: Player collects missile_pickup and sees damage boost indicator
## Verifies that collecting a MissilePickup increases damage boost and shows UI indicator.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _pickup_collected: bool = false
var _sfx_played: bool = false


func _ready() -> void:
	print("=== Test: Player Collects Missile Pickup and Sees Damage Boost Indicator ===")

	# Track sfx calls
	_setup_audio_tracking()

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
	await _run_missile_pickup_test()


func _setup_audio_tracking() -> void:
	# Hook into AudioManager to track sfx calls
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_signal("sfx_played"):
			audio_manager.sfx_played.connect(_on_sfx_played)


func _on_sfx_played(sfx_name: String) -> void:
	if sfx_name == "pickup_collect":
		_sfx_played = true
		print("pickup_collect sfx played!")


func _run_missile_pickup_test() -> void:
	# Move player to a known position
	_player.position = Vector2(400, 768)
	await get_tree().process_frame

	# Check initial damage boost (should be 0)
	var initial_boost = 0
	if _player.has_method("get_damage_boost"):
		initial_boost = _player.get_damage_boost()
	print("Initial damage boost: %d" % initial_boost)

	# Spawn a Missile Pickup at player's exact position for immediate collision
	var pickup_scene = load("res://scenes/pickups/missile_pickup.tscn")
	if not pickup_scene:
		_fail("Could not load missile_pickup scene")
		return

	var missile_pickup = pickup_scene.instantiate()
	missile_pickup.position = _player.position
	missile_pickup.setup(missile_pickup.SpawnEdge.LEFT)

	# Connect to the collected signal
	missile_pickup.collected.connect(_on_pickup_collected)

	_main.add_child(missile_pickup)
	print("Missile Pickup spawned at player position: %s" % str(missile_pickup.position))

	# Wait for collision detection and collection
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# Check if pickup was collected
	if not _pickup_collected:
		_fail("Missile Pickup was not collected (collected signal not emitted)")
		return

	print("Missile pickup collected!")

	# Check if damage boost increased
	if not _player.has_method("get_damage_boost"):
		_fail("Player does not have get_damage_boost() method")
		return

	var new_boost = _player.get_damage_boost()
	print("Damage boost after collection: %d" % new_boost)

	if new_boost != initial_boost + 1:
		_fail("Expected damage boost to increase from %d to %d, got %d" % [initial_boost, initial_boost + 1, new_boost])
		return

	# Check if DamageBoostDisplay shows correct value
	var damage_display = _main.get_node_or_null("DamageBoostDisplay")
	if not damage_display:
		_fail("DamageBoostDisplay node not found in main scene")
		return

	# Check if the display is visible (should be visible when boost > 0)
	if not damage_display.visible:
		_fail("DamageBoostDisplay should be visible when damage boost is active")
		return

	# Check if the label shows "x2" (base 1 + 1 boost = 2)
	var label = damage_display.get_node_or_null("Container/Label")
	if not label:
		_fail("Label node not found in DamageBoostDisplay")
		return

	var expected_text = "x2"
	if label.text != expected_text:
		_fail("Expected label text '%s', got '%s'" % [expected_text, label.text])
		return

	print("DamageBoostDisplay shows: %s" % label.text)

	# Verify pickup_collect sfx was played (optional - not all setups track this)
	# We won't fail the test if we couldn't track audio, but we'll log it
	if _sfx_played:
		print("pickup_collect sfx was played")
	else:
		print("Note: Could not verify pickup_collect sfx (audio tracking may not be available)")

	print("Missile pickup collection works correctly!")
	_pass()


func _on_pickup_collected() -> void:
	_pickup_collected = true
	print("Missile pickup collected signal received!")


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
	print("Missile pickup collection works - increases damage boost and shows UI indicator.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
