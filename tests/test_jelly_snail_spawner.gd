extends Node2D
## Integration test: Jelly Snail enemy can be spawned via EnemySpawner
## Verifies EnemySpawner has jelly_snail_enemy_scene export and can spawn jelly_snail type.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _enemy_spawner: Node2D = null
var _main_scene: Node2D = null


func _ready() -> void:
	print("=== Test: Jelly Snail Spawner Integration ===")

	# Load Main scene which contains EnemySpawner
	var main_scene_path = "res://scenes/main.tscn"
	if not ResourceLoader.exists(main_scene_path):
		_fail("Main scene does not exist at: %s" % main_scene_path)
		return

	var main_scene = load(main_scene_path)
	if not main_scene:
		_fail("Could not load Main scene")
		return

	_main_scene = main_scene.instantiate()
	if not _main_scene:
		_fail("Could not instantiate Main scene")
		return

	add_child(_main_scene)
	await get_tree().process_frame

	# Find the EnemySpawner in Main scene
	_enemy_spawner = _main_scene.get_node_or_null("EnemySpawner")
	if not _enemy_spawner:
		_fail("Could not find EnemySpawner in Main scene")
		return

	print("Found EnemySpawner in Main scene")

	# Test 1: Verify EnemySpawner has jelly_snail_enemy_scene export
	if not "jelly_snail_enemy_scene" in _enemy_spawner:
		_fail("EnemySpawner missing jelly_snail_enemy_scene export property")
		return

	print("EnemySpawner has jelly_snail_enemy_scene property")

	# Test 2: Verify the scene is assigned
	if not _enemy_spawner.jelly_snail_enemy_scene:
		_fail("jelly_snail_enemy_scene is not assigned in EnemySpawner")
		return

	print("jelly_snail_enemy_scene is assigned")

	# Test 3: Spawn a jelly_snail via spawn_wave
	var initial_count = _enemy_spawner.get_active_count()
	_enemy_spawner.spawn_wave([{"enemy_type": "jelly_snail", "count": 1}])

	await get_tree().process_frame

	var after_spawn_count = _enemy_spawner.get_active_count()
	if after_spawn_count != initial_count + 1:
		_fail("spawn_wave with jelly_snail did not spawn enemy. Expected %d, got %d" % [initial_count + 1, after_spawn_count])
		return

	print("Jelly Snail spawned via spawn_wave successfully")

	# Test 4: Verify spawned enemy has jelly_snail script
	var jelly_snail_script_path = "res://scripts/enemies/jelly_snail_enemy.gd"
	var found_jelly_snail = false
	for child in _enemy_spawner.get_children():
		if child.get_script() and child.get_script().resource_path == jelly_snail_script_path:
			found_jelly_snail = true
			break

	if not found_jelly_snail:
		_fail("Spawned enemy is not a JellySnailEnemy (script check)")
		return

	print("Spawned enemy verified as JellySnailEnemy")

	# Clean up
	_enemy_spawner.clear_all()

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Jelly Snail can be spawned via EnemySpawner.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
