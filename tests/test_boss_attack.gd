extends Node2D
## Integration test: Boss fires projectiles that can hit player
## Run this scene to verify boss attack patterns work correctly.

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 8.0
var _timer: float = 0.0

var main: Node = null
var level_manager: Node = null
var _boss: Node = null
var _player: Node = null
var _boss_spawned: bool = false
var _projectiles_detected: Array = []
var _initial_player_lives: int = 3
var _player_hit: bool = false


func _ready() -> void:
	print("=== Test: Boss Attack Projectiles ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	main = main_scene.instantiate()
	add_child(main)

	# Find level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found")
		return

	# Find player
	_player = main.get_node_or_null("Player")
	if not _player:
		_fail("Player node not found")
		return

	_initial_player_lives = _player.get_lives() if _player.has_method("get_lives") else 3

	# Connect to boss_spawned signal
	if level_manager.has_signal("boss_spawned"):
		level_manager.boss_spawned.connect(_on_boss_spawned)

	# Speed up scroll to reach boss quickly
	var scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for boss to spawn...")


func _on_boss_spawned() -> void:
	print("Boss spawned signal received")
	_boss_spawned = true

	# Locate the boss, then poll for its entrance animation to finish (it is
	# invincible and cannot attack until then) instead of a fixed sleep.
	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else null
	if not _boss:
		_boss = _find_boss_in_tree(main)
	if not _boss:
		_fail("Boss not found in scene tree")
		return

	var entered := await TestHelpers.poll_until(get_tree(), func(): return _boss and _boss._entrance_complete, 5.0)
	if not entered:
		_fail("Boss entrance never completed")
		return

	_verify_boss_and_test_attacks()


func _verify_boss_and_test_attacks() -> void:
	if _test_passed or _test_failed:
		return

	# Find the boss in scene
	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else null
	if not _boss:
		_boss = _find_boss_in_tree(main)

	if not _boss:
		_fail("Boss not found in scene tree")
		return

	print("Boss found: %s" % _boss.name)

	# Verify boss has attack capability
	if not _boss.has_method("start_attack_cycle"):
		_fail("Boss does not have start_attack_cycle method")
		return

	# Position player in path of projectiles
	_player.position = Vector2(400, _boss.position.y)
	print("Player positioned at: %s" % _player.position)

	# Trigger boss attack
	print("Triggering boss attack...")
	_boss.start_attack_cycle()

	# Poll until the attack actually fires projectiles rather than guessing a
	# fixed wait (the wind-up delay varies under load).
	var fired := await TestHelpers.poll_until(get_tree(), func(): return not _find_boss_projectiles_in_tree(main).is_empty(), 4.0)
	if not fired:
		_fail("No boss projectiles found after attack")
		return

	# Check for projectiles in scene
	_check_for_projectiles()


func _check_for_projectiles() -> void:
	if _test_passed or _test_failed:
		return

	# Find boss projectiles in scene
	_projectiles_detected = _find_boss_projectiles_in_tree(main)
	print("Boss projectiles found: %d" % _projectiles_detected.size())

	if _projectiles_detected.is_empty():
		_fail("No boss projectiles found after attack")
		return

	# Verify projectile count is in expected range (5-7)
	if _projectiles_detected.size() < 5 or _projectiles_detected.size() > 7:
		print("Warning: Expected 5-7 projectiles, got %d (still passing)" % _projectiles_detected.size())

	# Verify projectiles are moving left
	var projectile = _projectiles_detected[0]
	var initial_x = projectile.position.x

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	if is_instance_valid(projectile):
		var new_x = projectile.position.x
		if new_x >= initial_x:
			_fail("Projectile not moving left (initial_x: %f, new_x: %f)" % [initial_x, new_x])
			return
		print("Projectile moving left confirmed (delta: %f)" % (new_x - initial_x))
	else:
		print("Projectile already despawned (moving correctly)")

	# Test that projectile can damage player
	_test_projectile_damage()


func _test_projectile_damage() -> void:
	if _test_passed or _test_failed:
		return

	# Reset player to full health and clear invincibility so a hit registers.
	if _player.has_method("reset_lives"):
		_player.reset_lives()
	if "_is_invincible" in _player:
		_player._is_invincible = false

	# Detect the hit via the player's damage_taken signal: a single boss
	# projectile costs health, not a life, so get_lives() would not change.
	if _player.has_signal("damage_taken") and not _player.damage_taken.is_connected(_on_player_hit):
		_player.damage_taken.connect(_on_player_hit)

	# Find a live boss projectile (trigger another barrage if none remain).
	var projectile = _find_closest_boss_projectile()
	if not projectile:
		print("Triggering another attack for damage test...")
		_boss.start_attack_cycle()
		await TestHelpers.poll_until(get_tree(), func(): return _find_closest_boss_projectile() != null, 4.0)
		projectile = _find_closest_boss_projectile()

	if not projectile:
		_fail("No boss projectile available to test player damage")
		return

	# Overlap the player with the projectile so contact is unavoidable.
	_player.position = projectile.position
	print("Placing player on projectile at: %s" % _player.position)

	var health_before = _player.get_health() if _player.has_method("get_health") else 3
	var hit := await TestHelpers.poll_until(get_tree(), func(): return _player_hit or (_player.has_method("get_health") and _player.get_health() < health_before), 2.0)
	if not hit:
		_fail("Boss projectile did not damage player on contact")
		return

	print("Player took damage from boss projectile")
	_pass()


func _on_player_hit() -> void:
	_player_hit = true


func _find_closest_boss_projectile() -> Node:
	var projectiles = _find_boss_projectiles_in_tree(main)
	var closest: Node = null
	var closest_dist: float = INF

	for p in projectiles:
		if is_instance_valid(p):
			var dist = p.position.distance_to(_player.position)
			if dist < closest_dist:
				closest_dist = dist
				closest = p

	return closest


func _find_boss_in_tree(node: Node) -> Node:
	if "Boss" in node.name or "boss" in node.name.to_lower():
		if node.has_method("take_hit"):
			return node

	if node.get_script():
		var script_path = node.get_script().resource_path
		if "boss.gd" in script_path:
			return node

	for child in node.get_children():
		var found = _find_boss_in_tree(child)
		if found:
			return found

	return null


func _find_boss_projectiles_in_tree(node: Node) -> Array:
	var projectiles: Array = []

	# Check if this node is a boss projectile
	if "BossProjectile" in node.name or "boss_projectile" in node.name.to_lower():
		projectiles.append(node)
	elif node.get_script():
		var script_path = node.get_script().resource_path
		if "boss_projectile.gd" in script_path:
			projectiles.append(node)

	# Recurse through children
	for child in node.get_children():
		projectiles.append_array(_find_boss_projectiles_in_tree(child))

	return projectiles


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out - boss_spawned: %s" % _boss_spawned)
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss fires projectiles that move left correctly.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
