extends Node2D
## Integration test: spawn_wave spawns mixed enemy types correctly
## - Call spawn_wave with multiple enemy types
## - Verify correct count of each type

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var _enemy_spawner: Node = null


func _ready() -> void:
	print("=== Test: spawn_wave Spawns Mixed Enemy Types ===")

	# Create enemy spawner node and attach script
	_enemy_spawner = Node2D.new()
	var script = load("res://scripts/enemies/enemy_spawner.gd")
	_enemy_spawner.set_script(script)
	add_child(_enemy_spawner)

	# Configure the spawner with all enemy scenes
	_enemy_spawner.stationary_enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	_enemy_spawner.patrol_enemy_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	_enemy_spawner.shooting_enemy_scene = load("res://scenes/enemies/shooting_enemy.tscn")
	_enemy_spawner.charger_enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")

	# Disable continuous spawning so only wave spawning happens
	_enemy_spawner.set_continuous_spawning(false)

	# Call spawn_wave with mixed enemy types (simulating a late-game wave)
	print("Calling spawn_wave with mixed types: 1 stationary, 1 patrol, 2 shooting, 1 charger...")
	_enemy_spawner.spawn_wave([
		{"enemy_type": "stationary", "count": 1},
		{"enemy_type": "patrol", "count": 1},
		{"enemy_type": "shooting", "count": 2},
		{"enemy_type": "charger", "count": 1}
	])

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
	# Count each enemy type as children of the spawner
	var stationary_count = 0
	var patrol_count = 0
	var shooting_count = 0
	var charger_count = 0
	var total_count = 0

	for child in _enemy_spawner.get_children():
		total_count += 1
		print("Found child: %s (is ShootingEnemy: %s, is ChargerEnemy: %s)" % [
			child.name,
			child is ShootingEnemy,
			child is ChargerEnemy
		])

		if child is ChargerEnemy:
			charger_count += 1
		elif child is ShootingEnemy:
			shooting_count += 1
		elif child is PatrolEnemy:
			patrol_count += 1
		elif child is BaseEnemy:
			# Stationary enemies are BaseEnemy without subclass
			stationary_count += 1

	print("Counts - Stationary: %d, Patrol: %d, Shooting: %d, Charger: %d (Total: %d)" % [
		stationary_count, patrol_count, shooting_count, charger_count, total_count
	])

	# Verify counts
	if stationary_count != 1:
		_fail("Expected 1 stationary enemy, got %d" % stationary_count)
		return
	if patrol_count != 1:
		_fail("Expected 1 patrol enemy, got %d" % patrol_count)
		return
	if shooting_count != 2:
		_fail("Expected 2 shooting enemies, got %d" % shooting_count)
		return
	if charger_count != 1:
		_fail("Expected 1 charger enemy, got %d" % charger_count)
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- spawn_wave correctly spawns all enemy types in a mixed wave")
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
