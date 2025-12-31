extends Node2D
## Integration test: Projectile is blocked by asteroid
## Projectiles should be destroyed when hitting asteroids, asteroid remains intact.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _projectile_ref: WeakRef = null
var _test_timeout: float = 3.0
var _timer: float = 0.0
var _asteroid_position_x: float = 0.0

@onready var player: Node = null
@onready var asteroid: Node = null


func _ready() -> void:
	print("=== Test: Projectile Blocked by Asteroid ===")

	# Load projectile scene
	var projectile_scene = load("res://scenes/projectile.tscn")
	if not projectile_scene:
		_fail("Could not load projectile scene")
		return

	# Create player
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return
	player = player_scene.instantiate()
	player.position = Vector2(400, 768)
	player.projectile_scene = projectile_scene
	add_child(player)

	# Create asteroid between player and right edge
	var asteroid_scene = load("res://scenes/obstacles/asteroid.tscn")
	if not asteroid_scene:
		_fail("Could not load asteroid scene")
		return
	asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(600, 768)  # Same Y as player, to the right
	asteroid.scroll_speed = 0.0  # Stop asteroid from moving during test
	_asteroid_position_x = asteroid.position.x
	add_child(asteroid)

	print("Test setup complete. Triggering player shoot...")

	# Fire a projectile
	player.shoot()

	# Get a weak reference to track the projectile
	await get_tree().process_frame
	await get_tree().process_frame
	for child in get_children():
		if child.name.begins_with("Projectile"):
			_projectile_ref = weakref(child)
			print("Tracking projectile at position: %s" % child.position)
			break

	if not _projectile_ref or not _projectile_ref.get_ref():
		_fail("Could not find projectile after shooting")
		return

	print("Waiting for projectile to hit asteroid...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out - projectile never hit asteroid")
		return

	var projectile = _projectile_ref.get_ref() if _projectile_ref else null

	# Projectile should be destroyed when hitting asteroid
	if projectile == null:
		# Projectile was destroyed - verify asteroid still exists
		if is_instance_valid(asteroid):
			print("Projectile destroyed, asteroid intact at x=%s" % asteroid.position.x)
			_pass()
		else:
			_fail("Asteroid was also destroyed - should be indestructible")
		return

	# If projectile passed the asteroid, that's a failure
	if projectile.position.x > _asteroid_position_x + 100:
		_fail("Projectile passed through asteroid without being destroyed")


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Projectile was blocked by asteroid (asteroid remains intact).")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
