extends Node2D
## Integration test: Enemy projectile damages player on contact
## - Spawn enemy projectile and player at same location
## - Verify projectile damages player and is destroyed

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

# Test state tracking
var _projectile: Node = null
var _player: Node = null
var _initial_lives: int = 0
var _damage_taken: bool = false


func _ready() -> void:
	print("=== Test: Enemy Projectile Damages Player ===")

	# Create player
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return
	_player = player_scene.instantiate()
	_player.position = Vector2(500, 768)
	add_child(_player)
	_initial_lives = _player.get_lives()

	# Connect to damage_taken signal
	_player.damage_taken.connect(_on_player_damage)

	# Give player a short delay to initialize
	await get_tree().create_timer(0.1).timeout

	# Create enemy projectile near player
	var projectile_scene = load("res://scenes/enemies/enemy_projectile.tscn")
	if not projectile_scene:
		_fail("Could not load enemy projectile scene")
		return
	_projectile = projectile_scene.instantiate()
	# Position projectile to the right of player, moving left into player
	_projectile.position = Vector2(550, 768)
	add_child(_projectile)

	print("Player position: (%f, %f)" % [_player.position.x, _player.position.y])
	print("Player initial lives: %d" % _initial_lives)
	print("Projectile position: (%f, %f)" % [_projectile.position.x, _projectile.position.y])
	print("Waiting for collision...")


func _on_player_damage() -> void:
	_damage_taken = true
	print("Player took damage! Lives: %d -> %d" % [_initial_lives, _player.get_lives()])


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check if projectile was destroyed (collision happened)
	if not is_instance_valid(_projectile) and _damage_taken:
		_pass()
		return

	# Check for timeout
	if _timer >= _test_timeout:
		_evaluate_results()
		return


func _evaluate_results() -> void:
	if not _damage_taken:
		_fail("Projectile did not damage player within %f seconds" % _test_timeout)
		return

	if is_instance_valid(_projectile):
		_fail("Projectile was not destroyed after hitting player")
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- Projectile damaged player")
	print("- Projectile destroyed on contact")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("")
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
