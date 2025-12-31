extends Node2D
## Integration test: spawn_wave spawns ShootingEnemy when type is "shooting"
## - Call spawn_wave with enemy_type "shooting"
## - Verify ShootingEnemy is spawned

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var _enemy_spawner: Node = null


func _ready() -> void:
	print("=== Test: spawn_wave Spawns ShootingEnemy ===")

	# Create enemy spawner node and attach script
	_enemy_spawner = Node2D.new()
	var script = load("res://scripts/enemies/enemy_spawner.gd")
	_enemy_spawner.set_script(script)
	add_child(_enemy_spawner)

	# Configure the spawner with required scenes (including shooting enemy)
	_enemy_spawner.stationary_enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	_enemy_spawner.patrol_enemy_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	_enemy_spawner.shooting_enemy_scene = load("res://scenes/enemies/shooting_enemy.tscn")
	_enemy_spawner.charger_enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")

	# Disable continuous spawning so only wave spawning happens
	_enemy_spawner.set_continuous_spawning(false)

	# Call spawn_wave with shooting enemy type
	print("Calling spawn_wave with shooting enemy type, count=2...")
	_enemy_spawner.spawn_wave([{"enemy_type": "shooting", "count": 2}])

	# Wait a frame for spawning to complete
	await get_tree().process_frame
	await get_tree().process_frame

	_evaluate_results()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _evaluate_results() -> void:
	# Check for ShootingEnemy instances as children of the spawner
	var shooting_count = 0

	for child in _enemy_spawner.get_children():
		print("Found child: %s (type: %s)" % [child.name, child.get_class()])
		if child is ShootingEnemy:
			shooting_count += 1
			print("Found ShootingEnemy at position: %s" % child.position)

	print("Total ShootingEnemy count: %d (expected: 2)" % shooting_count)

	if shooting_count != 2:
		_fail("Expected 2 ShootingEnemies to spawn, got %d" % shooting_count)
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- spawn_wave correctly spawns ShootingEnemy when enemy_type is 'shooting'")
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
