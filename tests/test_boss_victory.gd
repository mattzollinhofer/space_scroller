extends Node2D
## Integration test: Defeating boss shows victory sequence
## Run this scene to verify boss defeat triggers screen shake, explosion, and level complete.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 25.0
var _timer: float = 0.0

var main: Node = null
var level_manager: Node = null
var _boss: Node = null
var _boss_spawned: bool = false
var _boss_defeated_signal_received: bool = false
var _screen_shake_detected: bool = false
var _explosion_detected: bool = false
var _level_complete_shown: bool = false
var _health_bar_hidden: bool = false

## Track main node position for shake detection
var _initial_main_position: Vector2 = Vector2.ZERO
var _position_samples: Array = []


func _ready() -> void:
	print("=== Test: Boss Victory Sequence ===")

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

	# Connect to boss_spawned signal
	if level_manager.has_signal("boss_spawned"):
		level_manager.boss_spawned.connect(_on_boss_spawned)

	# Speed up scroll to reach boss quickly
	var scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for boss to spawn...")


func _on_boss_spawned() -> void:
	print("Boss spawned signal received")
	_boss_spawned = true

	# Wait for boss entrance to complete
	await get_tree().create_timer(2.5).timeout

	_verify_boss_and_defeat()


func _verify_boss_and_defeat() -> void:
	if _test_passed or _test_failed:
		return

	# Find the boss
	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else null
	if not _boss:
		_boss = _find_boss_in_tree(main)

	if not _boss:
		_fail("Boss not found in scene tree")
		return

	print("Boss found: %s" % _boss.name)

	# Connect to boss_defeated signal
	if _boss.has_signal("boss_defeated"):
		_boss.boss_defeated.connect(_on_boss_defeated)

	# Store initial main node position for shake detection
	if main is Node2D:
		_initial_main_position = main.position
		print("Initial main position: %s" % _initial_main_position)

	# Deal 13 damage to defeat boss
	print("Defeating boss (dealing 13 damage)...")
	for i in range(13):
		if _boss and is_instance_valid(_boss) and _boss.has_method("take_hit"):
			_boss.take_hit(1)
			await get_tree().process_frame

	# Start monitoring for effects
	_start_effect_monitoring()


func _on_boss_defeated() -> void:
	print("boss_defeated signal received!")
	_boss_defeated_signal_received = true


func _start_effect_monitoring() -> void:
	# Monitor for effects over the next 2 seconds
	var monitor_duration = 2.0
	var monitor_start = Time.get_ticks_msec()

	while (Time.get_ticks_msec() - monitor_start) < (monitor_duration * 1000):
		await get_tree().process_frame

		# Check for screen shake (main node position change)
		if not _screen_shake_detected:
			_check_screen_shake()

		# Check for explosion
		if not _explosion_detected:
			_check_explosion()

		# Check if health bar is hidden
		if not _health_bar_hidden:
			_check_health_bar_hidden()

	# Wait additional time for level complete screen
	await get_tree().create_timer(1.5).timeout

	# Check for level complete screen
	_check_level_complete_screen()

	# Verify results
	_verify_victory_sequence()


func _check_screen_shake() -> void:
	if main is Node2D:
		# Sample the main node position
		_position_samples.append(main.position)

		# Check if position differs from initial (indicates shake)
		if main.position != _initial_main_position:
			_screen_shake_detected = true
			print("Screen shake detected! Main position: %s" % main.position)


func _check_explosion() -> void:
	# Look for explosion sprite in scene
	var explosion = _find_explosion_in_tree(main)
	if explosion:
		_explosion_detected = true
		print("Explosion sprite detected!")


func _check_health_bar_hidden() -> void:
	var health_bar = level_manager.get_boss_health_bar() if level_manager.has_method("get_boss_health_bar") else null
	if not health_bar:
		health_bar = _find_health_bar_in_tree(main)

	if health_bar:
		if not health_bar.visible:
			_health_bar_hidden = true
			print("Boss health bar hidden!")


func _check_level_complete_screen() -> void:
	var level_complete_screen = main.get_node_or_null("LevelCompleteScreen")
	if level_complete_screen and level_complete_screen.visible:
		_level_complete_shown = true
		print("Level complete screen shown!")


func _verify_victory_sequence() -> void:
	if _test_passed or _test_failed:
		return

	print("")
	print("=== Victory Sequence Results ===")
	print("boss_defeated signal: %s" % _boss_defeated_signal_received)
	print("Screen shake detected: %s" % _screen_shake_detected)
	print("Explosion detected: %s" % _explosion_detected)
	print("Health bar hidden: %s" % _health_bar_hidden)
	print("Level complete shown: %s" % _level_complete_shown)
	print("")

	# Check all acceptance criteria
	if not _boss_defeated_signal_received:
		_fail("boss_defeated signal was not emitted")
		return

	if not _screen_shake_detected:
		_fail("Screen shake effect was not detected")
		return

	if not _explosion_detected:
		_fail("Explosion animation was not detected")
		return

	if not _health_bar_hidden:
		_fail("Boss health bar was not hidden on defeat")
		return

	if not _level_complete_shown:
		_fail("Level complete screen was not shown after explosion")
		return

	_pass()


func _find_boss_in_tree(node: Node) -> Node:
	if "Boss" in node.name or "boss" in node.name.to_lower():
		if node.has_method("take_hit"):
			return node

	if node.get_script():
		var script_path = node.get_script().resource_path
		if "boss.gd" in script_path:
			return node

	for child in node.get_children():
		var found = _find_boss_in_tree(child)
		if found:
			return found

	return null


func _find_explosion_in_tree(node: Node) -> Sprite2D:
	if node is Sprite2D:
		if node.texture:
			var texture_path = node.texture.resource_path if node.texture.resource_path else ""
			if "explosion" in texture_path.to_lower():
				return node

	for child in node.get_children():
		var found = _find_explosion_in_tree(child)
		if found:
			return found

	return null


func _find_health_bar_in_tree(node: Node) -> Node:
	if "BossHealthBar" in node.name or "boss_health" in node.name.to_lower():
		return node

	if node.get_script():
		var script_path = node.get_script().resource_path
		if "boss_health_bar.gd" in script_path:
			return node

	for child in node.get_children():
		var found = _find_health_bar_in_tree(child)
		if found:
			return found

	return null


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out - boss_spawned: %s, boss_defeated: %s" % [_boss_spawned, _boss_defeated_signal_received])
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss victory sequence works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
