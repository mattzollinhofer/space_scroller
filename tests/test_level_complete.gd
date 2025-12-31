extends Node2D
## Integration test: Level complete screen shows after boss is defeated
## Run this scene to verify level completion flow works correctly.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 20.0
var _timer: float = 0.0

var main: Node = null
var level_manager: Node = null
var level_complete_screen: Node = null
var scroll_controller: Node = null
var _level_completed_emitted: bool = false
var _boss_spawned: bool = false
var _boss_entered: bool = false


func _ready() -> void:
	print("=== Test: Level Complete (After Boss) ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	main = main_scene.instantiate()
	add_child(main)

	# Find level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found")
		return

	# Check for level_completed signal
	if not level_manager.has_signal("level_completed"):
		_fail("LevelManager does not have 'level_completed' signal")
		return

	# Connect to level_completed signal
	level_manager.level_completed.connect(_on_level_completed)

	# Connect to boss_spawned signal if available
	if level_manager.has_signal("boss_spawned"):
		level_manager.boss_spawned.connect(_on_boss_spawned)

	# Find level complete screen
	level_complete_screen = main.get_node_or_null("LevelCompleteScreen")
	if not level_complete_screen:
		_fail("LevelCompleteScreen node not found in main scene")
		return

	# Speed up scroll to finish level quickly
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		# At 9000px total distance, 9000 px/s = 1 second to finish
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for level completion...")


func _on_level_completed() -> void:
	print("level_completed signal emitted!")
	_level_completed_emitted = true


func _on_boss_spawned() -> void:
	print("boss_spawned signal emitted!")
	_boss_spawned = true

	# Wait a frame for boss to be added to scene
	await get_tree().process_frame

	# Find the boss and connect to its boss_entered signal
	var boss = main.get_node_or_null("Boss")
	if boss:
		if boss.has_signal("boss_entered"):
			boss.boss_entered.connect(_on_boss_entered)
		# Wait for entrance animation (2 seconds + margin)
		print("Waiting for boss entrance animation...")
		await get_tree().create_timer(2.5).timeout
		_defeat_boss()
	else:
		_fail("Boss not found in scene tree after boss_spawned signal")


func _on_boss_entered() -> void:
	print("boss_entered signal emitted!")
	_boss_entered = true


func _defeat_boss() -> void:
	var boss = main.get_node_or_null("Boss")
	if boss and boss.has_method("take_hit"):
		print("Defeating boss (dealing 15 damage)...")
		# Deal enough damage to kill boss (13 HP)
		for i in range(15):
			if boss and is_instance_valid(boss):
				boss.take_hit(1)
			await get_tree().process_frame

	# Wait for death animation and level complete screen
	print("Waiting for level complete screen...")
	await get_tree().create_timer(2.0).timeout

	_check_level_complete()


func _check_level_complete() -> void:
	if _test_passed or _test_failed:
		return

	# Check if level complete screen is visible
	if level_complete_screen and level_complete_screen.visible:
		print("Level complete screen is visible after boss defeat")
		_pass()
	else:
		_fail("Level complete screen not visible after boss defeat (visible: %s, boss_entered: %s)" % [(level_complete_screen.visible if level_complete_screen else "null"), _boss_entered])


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		var progress = level_manager.get_progress() if level_manager else -1
		_fail("Test timed out - progress: %s, level_completed emitted: %s, boss_spawned: %s, boss_entered: %s" % [progress, _level_completed_emitted, _boss_spawned, _boss_entered])
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level complete screen shows after boss is defeated.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
