extends Node2D
## Integration test: Projectile passes through asteroid without being destroyed
## Run this scene to verify projectiles don't interact with asteroids.

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
	print("=== Test: Projectile Asteroid Pass-through ===")

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
	asteroid.position = Vector2(700, 768)  # Same Y as player, to the right
	asteroid.scroll_speed = 0.0  # Stop asteroid from moving during test
	_asteroid_position_x = asteroid.position.x
	add_child(asteroid)

	print("Test setup complete. Triggering player shoot...")

	# Fire a projectile
	player.shoot()

	# Get a weak reference to track the projectile
	var projectiles = get_tree().get_nodes_in_group("projectiles") if get_tree().has_group("projectiles") else []
	# Alternative: find projectile by checking children
	await get_tree().process_frame
	for child in get_children():
		if child.name.begins_with("Projectile"):
			_projectile_ref = weakref(child)
			print("Tracking projectile at position: %s" % child.position)
			break

	if not _projectile_ref or not _projectile_ref.get_ref():
		# Try to find in parent since projectiles are added to parent
		for child in get_parent().get_children() if get_parent() else []:
			if child.name.begins_with("Projectile"):
				_projectile_ref = weakref(child)
				print("Tracking projectile (from parent) at position: %s" % child.position)
				break

	if not _projectile_ref or not _projectile_ref.get_ref():
		# Projectiles added to player's parent, which is this test node
		# Check immediate children again after frame
		await get_tree().process_frame
		for child in get_children():
			if child.name.begins_with("Projectile"):
				_projectile_ref = weakref(child)
				print("Tracking projectile (delayed) at position: %s" % child.position)
				break

	print("Waiting for projectile to pass asteroid position...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out")
		return

	# Check if we have a projectile reference
	var projectile = _projectile_ref.get_ref() if _projectile_ref else null

	# If projectile is gone (was destroyed), check if it was destroyed before passing asteroid
	if projectile == null:
		# Projectile was destroyed - check what happened
		# If asteroid is still there and projectile is gone, it might have been destroyed by asteroid
		# We need to check if projectile made it past asteroid
		if _timer < 0.5:
			# Too early - projectile shouldn't have reached right edge yet
			# Check if asteroid is still there
			if is_instance_valid(asteroid):
				_fail("Projectile was destroyed before passing asteroid (asteroid still exists)")
			else:
				_fail("Both projectile and asteroid were destroyed - unexpected interaction")
		else:
			# Projectile likely despawned at right edge - this is success
			_pass()
		return

	# Check if projectile has passed the asteroid position
	if projectile.position.x > _asteroid_position_x + 100:
		print("Projectile passed asteroid position! x=%s (asteroid was at x=%s)" % [projectile.position.x, _asteroid_position_x])
		_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Projectile passed through asteroid without being destroyed.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
