extends Node2D
## Integration test: Player shoots, projectile hits stationary enemy, enemy dies
## Run this scene to verify shooting mechanics work end-to-end.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _enemy_died: bool = false
var _projectile_spawned: bool = false
var _test_timeout: float = 5.0
var _timer: float = 0.0

@onready var player: Node = null
@onready var enemy: Node = null


func _ready() -> void:
	print("=== Test: Player Shooting - Enemy Destruction ===")

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
	player.projectile_scene = projectile_scene  # Assign projectile scene
	add_child(player)

	# Create stationary enemy to the right of player
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load enemy scene")
		return
	enemy = enemy_scene.instantiate()
	enemy.position = Vector2(800, 768)  # Same Y as player, to the right
	# Stop the enemy from scrolling during test
	enemy.scroll_speed = 0.0
	add_child(enemy)

	# Connect to enemy died signal
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	else:
		_fail("Enemy does not have 'died' signal")
		return

	# Check if player can shoot
	if not player.has_method("shoot"):
		_fail("Player does not have 'shoot' method - need to implement shooting")
		return

	print("Test setup complete. Triggering player shoot...")

	# Simulate shooting by calling the shoot method directly
	# (In a real game, this would be triggered by Input.is_action_pressed("shoot"))
	player.shoot()
	_projectile_spawned = true
	print("Projectile spawned, waiting for collision...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out - projectile did not reach enemy within %s seconds" % _test_timeout)
		return

	# Check if enemy has been destroyed
	if _enemy_died:
		_pass()


func _on_enemy_died() -> void:
	print("Enemy died signal received!")
	_enemy_died = true


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Player shot projectile, hit enemy, enemy died with explosion.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
