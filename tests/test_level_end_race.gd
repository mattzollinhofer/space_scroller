extends Node2D
## Integration test: Boss defeat and player death racing at the end of a level
## must not both show their end screens.
##
## Reproduces a bug where a stray boss projectile killing the player during
## the boss's 2.5s victory-explosion delay could show GAME OVER stacked on
## top of LEVEL COMPLETE. Both end screens pause the game tree when shown, so
## each case below runs on its own main scene instance rather than
## sequentially in one.

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 8.0
var _timer: float = 0.0


func _ready() -> void:
	print("=== Test: Level End Race (Boss Victory vs Player Death) ===")
	# Keep our own timeout tracking alive even if an end screen pauses the tree.
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not await _run_boss_defeated_first_case():
		return

	if not await _run_player_died_first_case():
		return

	_pass()


## Case 1: boss defeated first, then player dies during the 2.5s explosion
## window. Level complete must win; game over must never show.
func _run_boss_defeated_first_case() -> bool:
	var main = _instantiate_main()
	if not main:
		return false

	var level_manager = main.get_node_or_null("LevelManager")
	var game_over_screen = main.get_node_or_null("GameOverScreen")
	var level_complete_screen = main.get_node_or_null("LevelCompleteScreen")
	if not _validate_nodes("Case 1", level_manager, game_over_screen, level_complete_screen):
		return false

	# Boss defeated first: runs synchronously up to its 2.5s await, so the
	# guard is set before this call returns.
	level_manager._on_boss_defeated()

	# Player dies during the explosion window: must be ignored by the guard.
	level_manager._on_player_died()

	if game_over_screen.visible:
		_fail("Case 1: game over screen shown after boss already claimed the level end")
		return false

	# Let the boss victory's pending 2.5s timer resolve and confirm level
	# complete is the screen that actually wins the race.
	var completed := await TestHelpers.poll_until(get_tree(), func(): return level_complete_screen.visible, 4.0)
	if not completed:
		_fail("Case 1: level complete screen never shown after boss defeat")
		return false

	if game_over_screen.visible:
		_fail("Case 1: game over screen shown after level complete resolved")
		return false

	print("Case 1 passed: boss victory wins the race, game over stays suppressed.")
	_cleanup(main)
	return true


## Case 2: player dies first, then boss is defeated. Game over must win;
## level complete must never show.
func _run_player_died_first_case() -> bool:
	var main = _instantiate_main()
	if not main:
		return false

	var level_manager = main.get_node_or_null("LevelManager")
	var game_over_screen = main.get_node_or_null("GameOverScreen")
	var level_complete_screen = main.get_node_or_null("LevelCompleteScreen")
	if not _validate_nodes("Case 2", level_manager, game_over_screen, level_complete_screen):
		return false

	# Player dies first: this handler has no internal await, so the guard is
	# set and game over is shown before this call returns.
	level_manager._on_player_died()

	if not game_over_screen.visible:
		_fail("Case 2: game over screen not shown after player death")
		return false

	# Boss defeated after: must be ignored by the guard.
	level_manager._on_boss_defeated()

	# Prove the negative: poll past the 2.5s explosion window and confirm
	# level complete never appears (a fixed-delay assertion here would not
	# catch the bug, since the unguarded path only shows the screen after
	# that same 2.5s delay).
	var wrongly_shown := await TestHelpers.poll_until(get_tree(), func(): return level_complete_screen.visible, 2.8)
	if wrongly_shown:
		_fail("Case 2: level complete screen shown after game over already claimed the level end")
		return false

	print("Case 2 passed: game over wins the race, level complete stays suppressed.")
	_cleanup(main)
	return true


func _validate_nodes(case_label: String, level_manager: Node, game_over_screen: Node, level_complete_screen: Node) -> bool:
	if not level_manager:
		_fail("%s: LevelManager node not found" % case_label)
		return false
	if not game_over_screen:
		_fail("%s: GameOverScreen node not found" % case_label)
		return false
	if not level_complete_screen:
		_fail("%s: LevelCompleteScreen node not found" % case_label)
		return false
	return true


func _instantiate_main() -> Node:
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return null

	var main = main_scene.instantiate()
	add_child(main)
	return main


## Free the main scene instance and unpause the tree before the next case,
## since showing either end screen pauses the SceneTree.
func _cleanup(main: Node) -> void:
	main.queue_free()
	await get_tree().process_frame
	get_tree().paused = false


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
	print("Boss victory and game over are mutually exclusive; only one end screen ever shows.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
