extends Node2D
## Integration test: Ghost Eye enemy has correct properties
## Verifies Ghost Eye enemy scene loads with correct health, fire_rate, zigzag_speed, and sprite.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Ghost Eye Enemy Properties ===")

	# Test 1: Load ghost_eye_enemy scene
	var scene_path = "res://scenes/enemies/ghost_eye_enemy.tscn"
	if not ResourceLoader.exists(scene_path):
		_fail("Ghost Eye enemy scene does not exist at: %s" % scene_path)
		return

	var ghost_eye_scene = load(scene_path)
	if not ghost_eye_scene:
		_fail("Could not load Ghost Eye enemy scene")
		return

	print("Ghost Eye enemy scene loaded successfully")

	# Instantiate the enemy
	var enemy = ghost_eye_scene.instantiate()
	if not enemy:
		_fail("Could not instantiate Ghost Eye enemy")
		return

	# Add to scene tree so _ready() is called
	add_child(enemy)

	# Wait a frame for _ready() to complete
	await get_tree().process_frame

	# Test 2: Verify health is 3
	if not "health" in enemy:
		_fail("Ghost Eye enemy missing health property")
		return

	if enemy.health != 3:
		_fail("Ghost Eye health should be 3, got: %d" % enemy.health)
		return

	print("Ghost Eye health: %d (correct)" % enemy.health)

	# Test 3: Verify fire_rate is 1.0
	if not "fire_rate" in enemy:
		_fail("Ghost Eye enemy missing fire_rate property")
		return

	if abs(enemy.fire_rate - 1.0) > 0.01:
		_fail("Ghost Eye fire_rate should be 1.0, got: %f" % enemy.fire_rate)
		return

	print("Ghost Eye fire_rate: %f (correct)" % enemy.fire_rate)

	# Test 4: Verify zigzag_speed is in range 240-280
	if not "zigzag_speed" in enemy:
		_fail("Ghost Eye enemy missing zigzag_speed property")
		return

	if enemy.zigzag_speed < 240.0 or enemy.zigzag_speed > 280.0:
		_fail("Ghost Eye zigzag_speed should be 240-280, got: %f" % enemy.zigzag_speed)
		return

	print("Ghost Eye zigzag_speed: %f (correct, in range 240-280)" % enemy.zigzag_speed)

	# Test 5: Verify sprite texture is ghost-eye-enemy-1.png
	var sprite = enemy.get_node_or_null("Sprite2D")
	if not sprite:
		_fail("Ghost Eye enemy missing Sprite2D child")
		return

	if not sprite.texture:
		_fail("Ghost Eye Sprite2D has no texture")
		return

	var texture_path = sprite.texture.resource_path
	if not "ghost-eye-enemy-1.png" in texture_path:
		_fail("Ghost Eye sprite should be ghost-eye-enemy-1.png, got: %s" % texture_path)
		return

	print("Ghost Eye sprite: %s (correct)" % texture_path)

	# Clean up
	enemy.queue_free()

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Ghost Eye enemy has correct properties.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
