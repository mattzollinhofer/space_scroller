extends Node2D
## Integration test: Player collects star_pickup and gains health
## Verifies that collecting a StarPickup awards 500 bonus points and restores health.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _star_collected: bool = false
var _score_before_collection: int = 0


func _ready() -> void:
	print("=== Test: Player Collects Star Pickup and Gains Health ===")

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
	await _run_star_pickup_test()


func _run_star_pickup_test() -> void:
	# Reset score to ensure clean state
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").reset_score()

	# Reduce player health so gain_health() will succeed
	# Directly set health below max for clean testing
	_player._health = 1
	await get_tree().process_frame

	# Get initial score and player health
	var initial_score = _get_current_score()
	var health_before = _player.get_health() if _player.has_method("get_health") else -1
	print("Initial score: %d, Player health: %d" % [initial_score, health_before])
	_score_before_collection = initial_score

	# Move player to a known position, away from any obstacles
	_player.position = Vector2(300, 768)
	await get_tree().process_frame

	# Spawn a Star Pickup at player's exact position for immediate collision
	var star_scene = load("res://scenes/pickups/star_pickup.tscn")
	if not star_scene:
		_fail("Could not load star_pickup scene")
		return

	var star_pickup = star_scene.instantiate()
	# Place star at exact player position for immediate collection
	star_pickup.position = _player.position
	star_pickup.setup(StarPickup.SpawnEdge.LEFT)

	# Connect to the collected signal to know when it's collected
	star_pickup.collected.connect(_on_star_collected)

	_main.add_child(star_pickup)
	print("Star Pickup spawned at player position: %s" % str(star_pickup.position))

	# Wait for collision detection and collection (should be immediate)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	# Give a moment for all signals to propagate
	await get_tree().create_timer(0.1).timeout

	# Check if star was collected
	if not _star_collected:
		_fail("Star Pickup was not collected (collected signal not emitted)")
		return

	# Check score increased by 500 points
	var new_score = _get_current_score()
	print("Score after collecting Star Pickup: %d" % new_score)

	var expected_score = _score_before_collection + 500
	if new_score != expected_score:
		_fail("Expected score %d after collecting Star Pickup, got %d" % [expected_score, new_score])
		return

	# Check that player gained health
	var health_after = _player.get_health() if _player.has_method("get_health") else -1
	print("Health after collection: %d" % health_after)

	if health_after != health_before + 1:
		_fail("Expected player to gain health (from %d to %d), but health is now %d" % [health_before, health_before + 1, health_after])
		return

	print("Star Pickup collection awarded 500 bonus points and restored health correctly!")
	_pass()


func _on_star_collected() -> void:
	_star_collected = true
	print("Star collected signal received!")


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
	print("Star pickup collection works correctly - awards 500 points and restores health.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
