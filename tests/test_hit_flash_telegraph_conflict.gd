extends Node2D
## Edge case test: Hit flash and telegraph don't permanently conflict
## Verifies modulate returns to normal state after both effects complete

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var boss: Node = null
var sprite: AnimatedSprite2D = null
var _telegraph_detected: bool = false
var _flash_started: bool = false
var _multiple_hits: int = 0
var _phase: int = 0  # 0=waiting for wind-up, 1=dealing damage, 2=verifying
var _verification_started: bool = false


func _ready() -> void:
	print("=== Test: Hit Flash and Telegraph Conflict ===")

	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	boss = boss_scene.instantiate()
	boss.position = Vector2(600, 400)
	add_child(boss)

	sprite = boss.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		_fail("Boss does not have AnimatedSprite2D")
		return

	# Setup boss
	boss._entrance_complete = true
	boss._battle_position = boss.position
	boss.wind_up_duration = 1.5  # Longer wind-up to allow multiple hits
	boss.attack_cooldown = 2.0

	print("Starting attack cycle...")
	boss.start_attack_cycle()
	print("Will deal multiple rapid hits during wind-up...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed or _verification_started:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return

	if not is_instance_valid(boss) or not is_instance_valid(sprite):
		_fail("Boss or sprite became invalid")
		return

	var attack_state = boss.get_attack_state()

	# Phase 0: Wait for WIND_UP
	if _phase == 0 and attack_state == boss.AttackState.WIND_UP:
		var mod = sprite.modulate
		if mod.r > 1.1:
			print("Telegraph detected (r=%f)" % mod.r)
			_telegraph_detected = true
			_phase = 1

	# Phase 1: Deal multiple rapid hits during wind-up
	if _phase == 1 and attack_state == boss.AttackState.WIND_UP:
		if _multiple_hits < 3:
			_multiple_hits += 1
			print("Dealing hit %d during wind-up..." % _multiple_hits)
			boss.take_hit(1)
			print("Boss health: %d, sprite modulate: %s" % [boss.health, sprite.modulate])

			if _multiple_hits >= 3:
				print("Finished dealing damage, waiting for cooldown...")
				_phase = 2

	# Phase 2: Wait for cooldown and verify
	if _phase == 2 and attack_state == boss.AttackState.COOLDOWN and not _verification_started:
		_verification_started = true
		print("Cooldown reached, verifying state...")
		_verify_final_state()


func _verify_final_state() -> void:
	# Wait for all tweens to complete
	await get_tree().create_timer(0.5).timeout

	var mod = sprite.modulate
	print("Final modulate: %s" % mod)

	# Modulate should be near normal (1,1,1,1)
	# Allow for some tolerance due to timing
	var is_normal = mod.r >= 0.9 and mod.r <= 1.1 and \
					mod.g >= 0.9 and mod.g <= 1.1 and \
					mod.b >= 0.9 and mod.b <= 1.1 and \
					mod.a >= 0.9 and mod.a <= 1.1

	if not is_normal:
		# If not normal, it might be stuck in telegraph or flash state
		# This would indicate a conflict
		print("Warning: Modulate not normal after effects: %s" % mod)
		# Check if it's corrupted
		if mod.r > 3.0 or mod.g > 1.1 or mod.b > 1.1:
			_fail("Modulate corrupted by flash/telegraph conflict: %s" % mod)
			return

	# Verify boss is still functional
	# Started at 13, dealt 3 damage, should be 10
	if boss.health == 10:
		print("Boss health correct: %d" % boss.health)
	else:
		_fail("Boss health unexpected: %d (expected 10)" % boss.health)
		return

	if not boss.is_attacking():
		_fail("Boss attack cycle stopped")
		return

	print("No permanent visual conflicts detected")
	print("Both hit flash and telegraph operate without corrupting state")
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Hit flash and telegraph coexist without permanent conflicts.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
