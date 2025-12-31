extends Node2D
## Integration test: Boss has aggressive attack parameters
## Verifies attack_cooldown is 1.3s and projectile speed is 750.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Boss Aggressive Parameters ===")

	# Load the boss scene directly to check parameters
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	var boss = boss_scene.instantiate()
	add_child(boss)

	# Load boss projectile scene to check speed
	var projectile_scene = load("res://scenes/enemies/boss_projectile.tscn")
	if not projectile_scene:
		_fail("Could not load boss projectile scene")
		return

	var projectile = projectile_scene.instantiate()
	add_child(projectile)

	# Test 1: Check attack_cooldown
	print("Checking attack_cooldown...")
	var attack_cooldown = boss.attack_cooldown
	print("  attack_cooldown: %f (expected: 1.3)" % attack_cooldown)
	if abs(attack_cooldown - 1.3) > 0.01:
		_fail("attack_cooldown is %f, expected 1.3" % attack_cooldown)
		return
	print("  PASS: attack_cooldown is 1.3")

	# Test 2: Check wind_up_duration
	print("Checking wind_up_duration...")
	var wind_up_duration = boss.wind_up_duration
	print("  wind_up_duration: %f (expected: 0.35)" % wind_up_duration)
	if abs(wind_up_duration - 0.35) > 0.01:
		_fail("wind_up_duration is %f, expected 0.35" % wind_up_duration)
		return
	print("  PASS: wind_up_duration is 0.35")

	# Test 3: Check projectile speed
	print("Checking projectile speed...")
	var projectile_speed = projectile.speed
	print("  projectile speed: %f (expected: 750)" % projectile_speed)
	if abs(projectile_speed - 750.0) > 0.01:
		_fail("projectile speed is %f, expected 750" % projectile_speed)
		return
	print("  PASS: projectile speed is 750")

	# Test 4: Check boss health remains at 13
	print("Checking boss health...")
	var boss_health = boss.health
	print("  boss health: %d (expected: 13)" % boss_health)
	if boss_health != 13:
		_fail("boss health is %d, expected 13" % boss_health)
		return
	print("  PASS: boss health is 13")

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss has aggressive parameters: attack_cooldown=1.3, wind_up_duration=0.35, projectile_speed=750")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(1)
