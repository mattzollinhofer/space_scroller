extends Node2D
## Edge case test: Projectile trail uses local_coords=false for natural fade
## Verifies trail configuration allows particles to fade naturally
## (In Godot, particles with local_coords=false persist visually after emitter is freed)

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var projectile: Node = null


func _ready() -> void:
	print("=== Test: Projectile Trail Cleanup Behavior ===")

	# Load and spawn a projectile
	var projectile_scene = load("res://scenes/projectile.tscn")
	if not projectile_scene:
		_fail("Could not load projectile scene")
		return

	projectile = projectile_scene.instantiate()
	projectile.position = Vector2(500, 400)
	add_child(projectile)

	print("Projectile spawned, checking trail configuration for proper cleanup...")

	# Allow one frame for the scene to be ready
	await get_tree().process_frame

	_run_tests()


func _run_tests() -> void:
	# Get the trail particles node
	var particles = projectile.get_node_or_null("TrailParticles")
	if particles == null:
		for child in projectile.get_children():
			if child is CPUParticles2D:
				particles = child
				break

	if particles == null:
		_fail("Projectile does not have CPUParticles2D child")
		return

	print("Found CPUParticles2D: %s" % particles.name)

	# Test 1: Verify local_coords is false
	# This is essential for particles to persist visually after emitter is freed
	# When local_coords=false, particles are rendered in global space
	if particles.local_coords:
		_fail("Trail particles should use local_coords=false for natural fade behavior")
		return

	print("local_coords: false (particles render in global space)")

	# Test 2: Verify reasonable lifetime for trail fade
	# Particles should have enough lifetime to be visible but short enough to not linger
	var lifetime = particles.lifetime
	if lifetime < 0.2 or lifetime > 0.6:
		_fail("Trail lifetime should be 0.3-0.5s for natural fade, got: %s" % lifetime)
		return

	print("lifetime: %s seconds (appropriate for trail fade)" % lifetime)

	# Test 3: Verify particles are continuously emitting (not one_shot)
	if particles.one_shot:
		_fail("Trail particles should not be one_shot (continuous emission)")
		return

	print("one_shot: false (continuous trail emission)")

	# Test 4: Verify emitting is true
	if not particles.emitting:
		_fail("Trail particles should be emitting")
		return

	print("emitting: true")

	# Test 5: Verify color ramp includes fade (alpha goes to 0)
	# The gradient should fade particles out over their lifetime
	var gradient = particles.color_ramp
	if gradient:
		# Check if the last color in gradient has low alpha (fade out)
		var point_count = gradient.get_point_count()
		if point_count > 0:
			var last_color = gradient.get_color(point_count - 1)
			if last_color.a > 0.1:
				print("Warning: Trail gradient may not fade to transparent (last alpha: %s)" % last_color.a)
			else:
				print("color_ramp: fades to transparent (alpha: %s)" % last_color.a)
	else:
		print("color_ramp: not set (uses default particle color)")

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
	print("=== TEST PASSED ===")
	print("Trail particles configured correctly for natural fade when projectile despawns.")
	print("(local_coords=false means particles persist visually in global space)")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
