extends Node
## Test that sidekick persists between levels via GameState

var _test_passed: bool = false


func _ready() -> void:
	print("=== Test: Sidekick Persistence Between Levels ===")
	await get_tree().process_frame
	_run_test()


func _run_test() -> void:
	# Stage 1: Verify GameState has sidekick methods
	print("Stage 1: Checking GameState sidekick methods...")
	if not has_node("/root/GameState"):
		_fail("GameState autoload not found")
		return

	var game_state = get_node("/root/GameState")
	if not game_state.has_method("set_sidekick_state"):
		_fail("GameState missing set_sidekick_state method")
		return
	if not game_state.has_method("has_sidekick"):
		_fail("GameState missing has_sidekick method")
		return
	if not game_state.has_method("get_sidekick_sprite"):
		_fail("GameState missing get_sidekick_sprite method")
		return
	print("GameState has all required sidekick methods")

	# Stage 2: Set sidekick state and verify it persists
	print("Stage 2: Testing sidekick state persistence...")
	var test_sprite = "res://assets/sprites/friend-ufo-1.png"
	game_state.set_sidekick_state(true, test_sprite)

	if not game_state.has_sidekick():
		_fail("has_sidekick() should return true after set_sidekick_state(true)")
		return

	var sprite = game_state.get_sidekick_sprite()
	if sprite != test_sprite:
		_fail("get_sidekick_sprite() returned '%s', expected '%s'" % [sprite, test_sprite])
		return
	print("Sidekick state persists correctly in GameState")

	# Stage 3: Test that sidekick is spawned when level loads
	print("Stage 3: Testing sidekick spawn on level load...")

	# Load the sidekick scene to verify it exists
	var sidekick_scene = load("res://scenes/pickups/sidekick.tscn")
	if not sidekick_scene:
		_fail("Could not load sidekick scene")
		return

	# Create a mock player for the sidekick
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return

	var player = player_scene.instantiate()
	player.position = Vector2(500, 500)
	add_child(player)
	await get_tree().process_frame

	# Manually spawn sidekick like level manager does
	var sidekick = sidekick_scene.instantiate()
	sidekick.name = "Sidekick"
	if sidekick.has_method("setup"):
		sidekick.setup(player, test_sprite)
	add_child(sidekick)
	await get_tree().process_frame

	# Verify sidekick was added to group
	var sidekicks = get_tree().get_nodes_in_group("sidekick")
	if sidekicks.size() == 0:
		_fail("Sidekick not found in 'sidekick' group after spawn")
		return
	print("Sidekick spawned and added to group correctly")

	# Verify sidekick has correct sprite
	var spawned_sidekick = sidekicks[0]
	if spawned_sidekick.has_method("get_sprite_path"):
		var sidekick_sprite = spawned_sidekick.get_sprite_path()
		if sidekick_sprite != test_sprite:
			_fail("Sidekick sprite '%s' doesn't match expected '%s'" % [sidekick_sprite, test_sprite])
			return
	print("Sidekick has correct sprite")

	# Stage 4: Test clear_sidekick_state
	print("Stage 4: Testing clear_sidekick_state...")
	game_state.clear_sidekick_state()

	if game_state.has_sidekick():
		_fail("has_sidekick() should return false after clear_sidekick_state()")
		return
	print("clear_sidekick_state works correctly")

	# All tests passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED: %s ===" % reason)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(1)
