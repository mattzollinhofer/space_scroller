extends Node2D
## Edge case test: Telegraph handles boss taking damage during wind-up
## Verifies hit flash and telegraph don't conflict, both tween effects work

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var boss: Node = null
var sprite: AnimatedSprite2D = null
var _telegraph_detected: bool = false
var _hit_registered: bool = false
var _damage_dealt_during_windup: bool = false
var _verification_started: bool = false


func _ready() -> void:
	print("=== Test: Telegraph Resets on Damage During Wind-Up ===")

	# Load and spawn a boss
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	boss = boss_scene.instantiate()
	boss.position = Vector2(600, 400)
	add_child(boss)

	# Get the sprite
	sprite = boss.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		_fail("Boss does not have AnimatedSprite2D")
		return

	# Mark entrance as complete
	boss._entrance_complete = true
	boss._battle_position = boss.position

	# Use slower wind-up for testing
	boss.wind_up_duration = 1.0
	boss.attack_cooldown = 2.0

	# Start attack cycle
	print("Starting boss attack cycle with 1s wind-up...")
	boss.start_attack_cycle()

	print("Will deal damage during wind-up to test telegraph/flash interaction...")


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

	# Wait for WIND_UP state and detect telegraph
	if attack_state == boss.AttackState.WIND_UP:
		var current_modulate = sprite.modulate
		if current_modulate.r > 1.1 and not _telegraph_detected:
			print("Telegraph detected during WIND_UP (modulate: %s)" % current_modulate)
			_telegraph_detected = true

			# Now deal damage mid-wind-up
			if not _damage_dealt_during_windup:
				print("Dealing damage to boss during wind-up...")
				boss.take_hit(1)
				_damage_dealt_during_windup = true
				_hit_registered = true
				print("Damage dealt! Boss health: %d" % boss.health)

	# After attack executes, verify state is clean
	if _damage_dealt_during_windup and attack_state == boss.AttackState.COOLDOWN and not _verification_started:
		_verification_started = true
		print("Attack cycle completed after damage was dealt during wind-up")
		_verify_state()


func _verify_state() -> void:
	if not is_instance_valid(boss) or not is_instance_valid(sprite):
		_fail("Boss or sprite became invalid during verification")
		return

	# Both the telegraph and the hit flash should settle the sprite modulate back
	# to normal once the attack fires. Poll for the settled value instead of
	# sleeping a fixed grace - these tweens drive the exact property under test.
	var settled := await TestHelpers.poll_until(get_tree(), func(): return _modulate_is_reset(), 1.5)

	var current_modulate = sprite.modulate
	print("Final modulate state: %s" % current_modulate)

	# Hard-assert the reset the test name promises actually happened (not stuck in
	# the telegraph pulse or the hit-flash overbright).
	if not settled:
		_fail("Telegraph/flash did not reset modulate after damage during wind-up: %s" % current_modulate)
		return

	# Most importantly, verify boss is still functional
	if boss.health <= 0:
		_fail("Boss died unexpectedly")
		return

	# Verify attack cycle is still active
	if not boss.is_attacking():
		_fail("Boss attack cycle stopped after taking damage")
		return

	print("Boss is still functional after taking damage during wind-up")
	print("Telegraph and hit flash did not cause permanent state corruption")
	_pass()


func _modulate_is_reset() -> bool:
	if not is_instance_valid(sprite):
		return false
	var m = sprite.modulate
	return m.r <= 1.1 and m.g <= 1.1 and m.b <= 1.1


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Telegraph properly handles boss taking damage during wind-up.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
