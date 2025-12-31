extends Node2D
## Integration test: ChargerEnemy damages player on contact
## - Spawn ChargerEnemy, verify it damages player when they collide

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 2.0
var _timer: float = 0.0

var _player: Node = null
var _enemy: Node = null
var _initial_lives: int = 0
var _damage_taken: bool = false


func _ready() -> void:
	print("=== Test: ChargerEnemy Damages Player ===")

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

	print("Player position: (%f, %f)" % [_player.position.x, _player.position.y])
	print("Player initial lives: %d" % _initial_lives)

	# Create charger enemy positioned to collide with player
	var enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load charger enemy scene")
		return
	_enemy = enemy_scene.instantiate()
	# Position slightly to the right of player so it charges into player
	_enemy.position = Vector2(600, 768)
	add_child(_enemy)
	print("Enemy position: (%f, %f)" % [_enemy.position.x, _enemy.position.y])
	print("Waiting for collision...")


func _on_player_damage() -> void:
	_damage_taken = true
	print("Player took damage! Lives: %d -> %d" % [_initial_lives, _player.get_lives()])


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check if damage was taken
	if _damage_taken:
		_pass()
		return

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("ChargerEnemy did not damage player within %f seconds" % _test_timeout)
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- ChargerEnemy damaged player on contact")
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
