extends Node2D
## Integration test: Score increases when UFO Friend is collected
## Verifies that collecting a UFO Friend awards 500 bonus points.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _ufo_collected: bool = false
var _score_before_collection: int = 0


func _ready() -> void:
	print("=== Test: Score Increases When UFO Friend Collected ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	_main = main_scene.instantiate()
	add_child(_main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find the player
	_player = _main.get_node_or_null("Player")
	if not _player:
		_fail("Player node not found in main scene")
		return

	# Disable enemy spawning to have a clean test
	var enemy_spawner = _main.get_node_or_null("EnemySpawner")
	if enemy_spawner:
		enemy_spawner.set_continuous_spawning(false)
		enemy_spawner.clear_all()

	# Wait another frame for things to settle
	await get_tree().process_frame

	# Run the test
	await _run_ufo_friend_test()


func _run_ufo_friend_test() -> void:
	# Reset score to ensure clean state
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").reset_score()

	# Reduce player lives so gain_life() will succeed
	# Player starts at max lives, so we need to take damage first
	if _player.has_method("take_damage"):
		_player.take_damage()
		# Wait for damage processing
		await get_tree().process_frame
		await get_tree().process_frame

	# Get initial score and player lives
	var initial_score = _get_current_score()
	var player_lives = _player.get_lives() if _player.has_method("get_lives") else -1
	print("Initial score: %d, Player lives: %d" % [initial_score, player_lives])
	_score_before_collection = initial_score

	# Move player to a known position, away from any obstacles
	_player.position = Vector2(300, 768)
	await get_tree().process_frame

	# Spawn a UFO Friend at player's exact position for immediate collision
	var ufo_scene = load("res://scenes/pickups/ufo_friend.tscn")
	if not ufo_scene:
		_fail("Could not load UFO Friend scene")
		return

	var ufo_friend = ufo_scene.instantiate()
	# Place UFO at exact player position for immediate collection
	ufo_friend.position = _player.position
	ufo_friend.setup(UfoFriend.SpawnEdge.LEFT)

	# Connect to the collected signal to know when it's collected
	ufo_friend.collected.connect(_on_ufo_collected)

	_main.add_child(ufo_friend)
	print("UFO Friend spawned at player position: %s" % str(ufo_friend.position))

	# Wait for collision detection and collection (should be immediate)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	# Give a moment for all signals to propagate
	await get_tree().create_timer(0.1).timeout

	# Check if UFO was collected
	if not _ufo_collected:
		_fail("UFO Friend was not collected (collected signal not emitted)")
		return

	# Check score increased by 500 points
	var new_score = _get_current_score()
	print("Score after collecting UFO Friend: %d" % new_score)

	var expected_score = _score_before_collection + 500
	if new_score != expected_score:
		_fail("Expected score %d after collecting UFO Friend, got %d" % [expected_score, new_score])
		return

	print("UFO Friend collection awarded 500 bonus points correctly!")
	_pass()


func _on_ufo_collected() -> void:
	_ufo_collected = true
	print("UFO collected signal received!")


func _get_current_score() -> int:
	# Try to get score from ScoreManager autoload first
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("get_score"):
			return score_manager.get_score()
	return 0


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
	print("Score increases correctly when UFO Friend is collected.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
