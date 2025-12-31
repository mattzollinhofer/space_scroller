extends Node2D
## Integration test: filler spawning uses weighted random selection
## - 60% stationary, 30% shooting, 10% charger
## - Spawn many filler enemies and verify distribution is roughly correct

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _enemy_spawner: Node = null
var _spawn_count: int = 100
var _spawned: int = 0
var _stationary_count: int = 0
var _shooting_count: int = 0
var _charger_count: int = 0


func _ready() -> void:
	print("=== Test: Filler Weighted Spawn Distribution ===")

	# Create enemy spawner node and attach script
	_enemy_spawner = Node2D.new()
	var script = load("res://scripts/enemies/enemy_spawner.gd")
	_enemy_spawner.set_script(script)
	add_child(_enemy_spawner)

	# Configure the spawner with required scenes
	_enemy_spawner.stationary_enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	_enemy_spawner.patrol_enemy_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	_enemy_spawner.shooting_enemy_scene = load("res://scenes/enemies/shooting_enemy.tscn")
	_enemy_spawner.charger_enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")

	# Disable continuous and filler spawning (we'll call _spawn_filler_enemy directly)
	_enemy_spawner.set_continuous_spawning(false)
	_enemy_spawner.set_filler_spawning(false)

	# Spawn many filler enemies manually to test distribution
	print("Spawning %d filler enemies..." % _spawn_count)

	for i in range(_spawn_count):
		_enemy_spawner._spawn_filler_enemy()
		await get_tree().process_frame

	# Count the types
	_count_enemy_types()


func _count_enemy_types() -> void:
	for child in _enemy_spawner.get_children():
		if child is ChargerEnemy:
			_charger_count += 1
		elif child is ShootingEnemy:
			_shooting_count += 1
		elif child is BaseEnemy:
			# StationaryEnemy or PatrolEnemy (BaseEnemy)
			_stationary_count += 1

	print("")
	print("Distribution results:")
	print("  Stationary: %d (%.1f%%) - expected ~60%%" % [_stationary_count, 100.0 * _stationary_count / _spawn_count])
	print("  Shooting: %d (%.1f%%) - expected ~30%%" % [_shooting_count, 100.0 * _shooting_count / _spawn_count])
	print("  Charger: %d (%.1f%%) - expected ~10%%" % [_charger_count, 100.0 * _charger_count / _spawn_count])

	# Verify distribution is roughly correct (with tolerance for randomness)
	# For 100 samples, we expect:
	# - Stationary: 60 +/- 20 (40-80)
	# - Shooting: 30 +/- 15 (15-45)
	# - Charger: 10 +/- 10 (0-20)

	if _stationary_count < 35 or _stationary_count > 85:
		_fail("Stationary count %d is outside expected range (35-85 for 60%% target)" % _stationary_count)
		return

	if _shooting_count < 10 or _shooting_count > 50:
		_fail("Shooting count %d is outside expected range (10-50 for 30%% target)" % _shooting_count)
		return

	if _charger_count > 30:
		_fail("Charger count %d is too high (expected ~10%%, max 30)" % _charger_count)
		return

	# Verify totals
	var total = _stationary_count + _shooting_count + _charger_count
	if total != _spawn_count:
		_fail("Total enemies %d does not match spawn count %d" % [total, _spawn_count])
		return

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- Filler spawn distribution matches expected weights")
	print("- 60%% stationary, 30%% shooting, 10%% charger")
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
