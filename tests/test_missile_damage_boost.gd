extends Node2D
## Integration test: Boosted projectile deals extra damage to enemies
## Verifies that after collecting a missile pickup, player projectiles deal boosted damage.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _enemy: Node = null
var _enemy_died: bool = false
var _enemy_hit_count: int = 0


func _ready() -> void:
	print("=== Test: Boosted Projectile Deals Extra Damage ===")

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
	await _run_damage_boost_test()


func _run_damage_boost_test() -> void:
	# Move player to a known position
	_player.position = Vector2(200, 768)
	await get_tree().process_frame

	# Give the player 1 damage boost (simulating missile pickup collection)
	if not _player.has_method("add_damage_boost"):
		_fail("Player does not have add_damage_boost() method")
		return

	_player.add_damage_boost()
	var boost = _player.get_damage_boost()
	print("Damage boost set to: %d" % boost)

	if boost != 1:
		_fail("Expected damage boost of 1, got %d" % boost)
		return

	# Spawn an enemy ahead of the player (use patrol_enemy)
	var enemy_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load patrol_enemy scene")
		return

	_enemy = enemy_scene.instantiate()
	_enemy.position = Vector2(500, 768)  # Ahead of player
	_enemy.scroll_speed = 0  # Stop movement for easier testing
	_enemy.zigzag_speed = 0  # Stop zigzag for easier testing

	# Connect to enemy signals to track damage
	_enemy.died.connect(_on_enemy_died)
	_enemy.hit_by_projectile.connect(_on_enemy_hit)

	_main.add_child(_enemy)

	# Wait a frame for enemy _ready() to run, then set health
	await get_tree().process_frame
	_enemy.health = 2  # 2 health so boosted projectile (damage 2) kills in 1 hit
	print("Enemy spawned with health: %d at position %s" % [_enemy.health, str(_enemy.position)])

	# Player shoots - should fire a projectile with damage = 1 + 1 boost = 2
	print("Player shooting with x2 damage...")
	_player.shoot(true)

	# Wait for projectile to reach enemy (projectile speed is 900 px/s, distance is ~300 px)
	# Should take about 0.33 seconds, waiting 0.5 to be safe
	await get_tree().create_timer(0.5).timeout

	# Check results
	if not _enemy_died:
		var remaining_health = _enemy.health if is_instance_valid(_enemy) else -1
		_fail("Enemy should have died from boosted projectile (2 damage to 2 health enemy). Remaining health: %d, Hit count: %d" % [remaining_health, _enemy_hit_count])
		return

	print("Enemy died from single x2 boosted projectile!")

	# Now test stacking - spawn new enemy with 3 health, give player another boost
	_player.add_damage_boost()
	boost = _player.get_damage_boost()
	print("Damage boost now: %d (expecting 2)" % boost)

	if boost != 2:
		_fail("Expected damage boost of 2 after second add, got %d" % boost)
		return

	# Spawn new enemy with 3 health
	_enemy_died = false
	_enemy_hit_count = 0
	_enemy = enemy_scene.instantiate()
	_enemy.position = Vector2(500, 768)
	_enemy.scroll_speed = 0
	_enemy.zigzag_speed = 0
	_enemy.died.connect(_on_enemy_died)
	_enemy.hit_by_projectile.connect(_on_enemy_hit)
	_main.add_child(_enemy)

	# Wait a frame for enemy _ready() to run, then set health
	await get_tree().process_frame
	_enemy.health = 3  # 3 health so x3 projectile (damage 3) kills in 1 hit
	print("Second enemy spawned with health: %d" % _enemy.health)

	# Player shoots - should deal 1 + 2 boost = 3 damage
	print("Player shooting with x3 damage...")
	_player.shoot(true)

	await get_tree().create_timer(0.5).timeout

	if not _enemy_died:
		var remaining_health = _enemy.health if is_instance_valid(_enemy) else -1
		_fail("Enemy with 3 health should have died from x3 boosted projectile. Remaining health: %d, Hit count: %d" % [remaining_health, _enemy_hit_count])
		return

	print("Second enemy died from single x3 boosted projectile!")
	print("Damage boost stacking works correctly!")
	_pass()


func _on_enemy_died() -> void:
	_enemy_died = true
	print("Enemy died!")


func _on_enemy_hit() -> void:
	_enemy_hit_count += 1
	print("Enemy hit! (count: %d)" % _enemy_hit_count)


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
	print("Boosted projectiles deal extra damage - stacking works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
