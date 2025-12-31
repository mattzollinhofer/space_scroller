extends Node2D
## Integration test: ChargerEnemy despawns off-screen left
## - Spawn ChargerEnemy near left edge, verify it despawns when x < -100

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 2.0
var _timer: float = 0.0

var _enemy: Node = null


func _ready() -> void:
	print("=== Test: ChargerEnemy Despawns Off-Screen ===")

	# Create charger enemy near left edge
	var enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load charger enemy scene")
		return
	_enemy = enemy_scene.instantiate()
	# Position near left edge so it despawns quickly at ~450 px/s
	_enemy.position = Vector2(400, 768)
	add_child(_enemy)
	print("Enemy position: (%f, %f)" % [_enemy.position.x, _enemy.position.y])
	print("Enemy charge speed: ~450 px/s")
	print("Expected despawn at x < -100")
	print("Expected time to despawn: ~1.1 seconds")
	print("Waiting for despawn...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Print position while enemy exists
	if is_instance_valid(_enemy):
		if int(_timer * 10) % 2 == 0:  # Print every ~0.2 seconds
			print("  Enemy x: %f" % _enemy.position.x)

	# Check if enemy despawned
	if not is_instance_valid(_enemy):
		_pass()
		return

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("ChargerEnemy did not despawn within %f seconds (x = %f)" % [_test_timeout, _enemy.position.x])
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- ChargerEnemy despawned when off-screen left")
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
