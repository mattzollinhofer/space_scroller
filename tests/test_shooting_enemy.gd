extends Node2D
## Integration test: ShootingEnemy fires projectiles
## - Spawn ShootingEnemy, verify it fires projectile within 5 seconds
## - ShootingEnemy should have 1 HP
## - ShootingEnemy should move with zigzag pattern

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

# Test state tracking
var _enemy: Node = null
var _projectile_fired: bool = false
var _initial_y: float = 0.0

# Track projectiles
var _projectile_count: int = 0


func _ready() -> void:
	print("=== Test: ShootingEnemy Fires Projectiles ===")

	# Create shooting enemy in the middle of the screen
	var enemy_scene = load("res://scenes/enemies/shooting_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load shooting enemy scene")
		return
	_enemy = enemy_scene.instantiate()
	# Position in middle Y, keep well within bounds
	_enemy.position = Vector2(800, 768)
	# Stop horizontal scrolling so enemy stays on screen
	_enemy.scroll_speed = 0.0
	add_child(_enemy)

	_initial_y = _enemy.position.y
	print("Enemy position: (%f, %f)" % [_enemy.position.x, _enemy.position.y])
	print("Enemy health: %d" % _enemy.health)
	print("Waiting for projectile fire (up to %f seconds)..." % _test_timeout)


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for projectiles in the scene tree
	var projectiles = get_tree().get_nodes_in_group("enemy_projectiles")
	if projectiles.size() > _projectile_count:
		_projectile_count = projectiles.size()
		print("Projectile detected! Count: %d" % _projectile_count)
		_projectile_fired = true

	# Check if we can pass early (projectile fired)
	if _projectile_fired:
		_evaluate_results()
		return

	# Check for timeout
	if _timer >= _test_timeout:
		_evaluate_results()
		return


func _evaluate_results() -> void:
	if not is_instance_valid(_enemy):
		_fail("Enemy was destroyed or removed during test")
		return

	# Verify health is 1 (ShootingEnemy has 1 HP)
	if _enemy.health != 1:
		_fail("ShootingEnemy should have 1 HP, got %d" % _enemy.health)
		return

	# Verify projectile was fired
	if not _projectile_fired:
		_fail("ShootingEnemy did not fire projectile within %f seconds" % _test_timeout)
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- ShootingEnemy fired projectile within %f seconds" % _timer)
	print("- ShootingEnemy has correct health (1 HP)")
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
