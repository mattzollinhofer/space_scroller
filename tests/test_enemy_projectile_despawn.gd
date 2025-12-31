extends Node2D
## Integration test: Enemy projectile despawns when off-screen left
## - Spawn projectile near left edge
## - Verify projectile is destroyed when it goes off left edge

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

# Test state tracking
var _projectile: Node = null


func _ready() -> void:
	print("=== Test: Enemy Projectile Despawns Off-Screen ===")

	# Create enemy projectile near left edge (should despawn quickly)
	var projectile_scene = load("res://scenes/enemies/enemy_projectile.tscn")
	if not projectile_scene:
		_fail("Could not load enemy projectile scene")
		return
	_projectile = projectile_scene.instantiate()
	# Position projectile near left edge
	_projectile.position = Vector2(100, 768)
	add_child(_projectile)

	print("Projectile position: (%f, %f)" % [_projectile.position.x, _projectile.position.y])
	print("Projectile speed: %f px/s" % _projectile.speed)
	print("Expected despawn at x < -100")
	var time_to_despawn = (100 + 100) / _projectile.speed  # distance / speed
	print("Expected time to despawn: ~%f seconds" % time_to_despawn)
	print("Waiting for despawn...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check if projectile was destroyed
	if not is_instance_valid(_projectile):
		_pass()
		return

	# Log position periodically
	if int(_timer * 10) % 5 == 0 and is_instance_valid(_projectile):
		print("  Projectile x: %f" % _projectile.position.x)

	# Check for timeout
	if _timer >= _test_timeout:
		_evaluate_results()
		return


func _evaluate_results() -> void:
	if is_instance_valid(_projectile):
		_fail("Projectile was not destroyed after %f seconds (still at x=%f)" % [_test_timeout, _projectile.position.x])
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- Projectile despawned when off-screen left")
	print("- Time to despawn: %f seconds" % _timer)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("")
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
