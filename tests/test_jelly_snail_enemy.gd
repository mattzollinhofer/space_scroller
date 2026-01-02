extends Node2D
## Integration test: Jelly Snail enemy has correct properties
## Verifies Jelly Snail enemy scene loads with correct health, fire_rate, zigzag_speed, and sprite.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Jelly Snail Enemy Properties ===")

	# Test 1: Load jelly_snail_enemy scene
	var scene_path = "res://scenes/enemies/jelly_snail_enemy.tscn"
	if not ResourceLoader.exists(scene_path):
		_fail("Jelly Snail enemy scene does not exist at: %s" % scene_path)
		return

	var jelly_snail_scene = load(scene_path)
	if not jelly_snail_scene:
		_fail("Could not load Jelly Snail enemy scene")
		return

	print("Jelly Snail enemy scene loaded successfully")

	# Instantiate the enemy
	var enemy = jelly_snail_scene.instantiate()
	if not enemy:
		_fail("Could not instantiate Jelly Snail enemy")
		return

	# Add to scene tree so _ready() is called
	add_child(enemy)

	# Wait a frame for _ready() to complete
	await get_tree().process_frame

	# Test 2: Verify health is 5
	if not "health" in enemy:
		_fail("Jelly Snail enemy missing health property")
		return

	if enemy.health != 5:
		_fail("Jelly Snail health should be 5, got: %d" % enemy.health)
		return

	print("Jelly Snail health: %d (correct)" % enemy.health)

	# Test 3: Verify fire_rate is 6.0
	if not "fire_rate" in enemy:
		_fail("Jelly Snail enemy missing fire_rate property")
		return

	if abs(enemy.fire_rate - 6.0) > 0.01:
		_fail("Jelly Snail fire_rate should be 6.0, got: %f" % enemy.fire_rate)
		return

	print("Jelly Snail fire_rate: %f (correct)" % enemy.fire_rate)

	# Test 4: Verify zigzag_speed is in range 60-80
	if not "zigzag_speed" in enemy:
		_fail("Jelly Snail enemy missing zigzag_speed property")
		return

	if enemy.zigzag_speed < 60.0 or enemy.zigzag_speed > 80.0:
		_fail("Jelly Snail zigzag_speed should be 60-80, got: %f" % enemy.zigzag_speed)
		return

	print("Jelly Snail zigzag_speed: %f (correct, in range 60-80)" % enemy.zigzag_speed)

	# Test 5: Verify sprite texture is jelly-snail-1.png
	var sprite = enemy.get_node_or_null("Sprite2D")
	if not sprite:
		_fail("Jelly Snail enemy missing Sprite2D child")
		return

	if not sprite.texture:
		_fail("Jelly Snail Sprite2D has no texture")
		return

	var texture_path = sprite.texture.resource_path
	if not "jelly-snail-1.png" in texture_path:
		_fail("Jelly Snail sprite should be jelly-snail-1.png, got: %s" % texture_path)
		return

	print("Jelly Snail sprite: %s (correct)" % texture_path)

	# Clean up
	enemy.queue_free()

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Jelly Snail enemy has correct properties.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
