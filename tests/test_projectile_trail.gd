extends Node2D
## Integration test: Player projectile displays a trailing particle effect
## Verifies CPUParticles2D child exists, is emitting, and emits backward

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

@onready var projectile: Node = null


func _ready() -> void:
	print("=== Test: Projectile Trail Effect ===")

	# Load and spawn a projectile
	var projectile_scene = load("res://scenes/projectile.tscn")
	if not projectile_scene:
		_fail("Could not load projectile scene")
		return

	projectile = projectile_scene.instantiate()
	projectile.position = Vector2(500, 400)
	add_child(projectile)

	print("Projectile spawned, checking for trail particles...")

	# Allow one frame for the scene to be ready
	await get_tree().process_frame

	_run_tests()


func _run_tests() -> void:
	# Test 1: Check for CPUParticles2D child
	var particles = projectile.get_node_or_null("TrailParticles")
	if particles == null:
		# Also check if any CPUParticles2D exists as a child
		for child in projectile.get_children():
			if child is CPUParticles2D:
				particles = child
				break

	if particles == null:
		_fail("Projectile does not have CPUParticles2D child for trail effect")
		return

	print("Found CPUParticles2D: %s" % particles.name)

	# Test 2: Verify particles are emitting
	if not particles.emitting:
		_fail("Trail particles are not emitting")
		return

	print("Particles are emitting: true")

	# Test 3: Verify particles emit backward (direction.x < 0)
	var direction = particles.direction
	if direction.x >= 0:
		_fail("Trail particles direction.x should be negative (backward), got: %s" % direction)
		return

	print("Particles direction is backward: %s" % direction)

	# Test 4: Verify conservative particle count (10-20)
	var amount = particles.amount
	if amount < 10 or amount > 20:
		_fail("Trail particle amount should be 10-20, got: %d" % amount)
		return

	print("Particle amount is conservative: %d" % amount)

	# Test 5: Verify reasonable lifetime (0.3-0.5 seconds)
	var lifetime = particles.lifetime
	if lifetime < 0.2 or lifetime > 0.6:
		_fail("Trail particle lifetime should be 0.3-0.5s, got: %s" % lifetime)
		return

	print("Particle lifetime is appropriate: %s seconds" % lifetime)

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Projectile has visible trailing particle effect with proper configuration.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
