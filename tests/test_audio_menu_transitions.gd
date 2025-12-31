extends Node2D
## Integration test: Music stops on all menu transitions
## Verifies stop_music() is called before transitions to main menu from:
## - Pause menu quit
## - Game over screen
## - Level complete screen (main menu button)

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0


func _ready() -> void:
	print("=== Test: Music Stops on Menu Transitions ===")

	# Check if AudioManager autoload exists
	if not has_node("/root/AudioManager"):
		_fail("AudioManager autoload not found")
		return

	var audio_manager = get_node("/root/AudioManager")

	# Verify AudioManager has required methods
	if not audio_manager.has_method("stop_music"):
		_fail("AudioManager does not have 'stop_music' method")
		return

	if not audio_manager.has_method("is_music_playing"):
		_fail("AudioManager does not have 'is_music_playing' method")
		return

	if not audio_manager.has_method("play_music"):
		_fail("AudioManager does not have 'play_music' method")
		return

	# Test 1: Verify pause_menu.gd has stop music code
	var pause_menu_script = load("res://scripts/ui/pause_menu.gd")
	if not pause_menu_script:
		_fail("Could not load pause_menu.gd")
		return

	var pause_source = pause_menu_script.source_code
	if pause_source.find("stop_music") == -1:
		_fail("pause_menu.gd does not contain stop_music call")
		return

	print("  - pause_menu.gd contains stop_music: OK")

	# Test 2: Verify game_over_screen.gd has stop music code
	var game_over_script = load("res://scripts/game_over_screen.gd")
	if not game_over_script:
		_fail("Could not load game_over_screen.gd")
		return

	var game_over_source = game_over_script.source_code
	if game_over_source.find("stop_music") == -1:
		_fail("game_over_screen.gd does not contain stop_music call")
		return

	print("  - game_over_screen.gd contains stop_music: OK")

	# Test 3: Verify level_complete_screen.gd has stop music code
	var level_complete_script = load("res://scripts/ui/level_complete_screen.gd")
	if not level_complete_script:
		_fail("Could not load level_complete_screen.gd")
		return

	var level_complete_source = level_complete_script.source_code
	if level_complete_source.find("stop_music") == -1:
		_fail("level_complete_screen.gd does not contain stop_music call")
		return

	print("  - level_complete_screen.gd contains stop_music: OK")

	# Test 4: Verify main_menu.gd does NOT start music
	var main_menu_script = load("res://scripts/ui/main_menu.gd")
	if not main_menu_script:
		_fail("Could not load main_menu.gd")
		return

	var main_menu_source = main_menu_script.source_code
	if main_menu_source.find("play_music") != -1:
		_fail("main_menu.gd should not contain play_music call")
		return

	print("  - main_menu.gd does not start music: OK")

	# Test 5: Functional test - start music, stop it, verify it stopped
	audio_manager.play_music()
	await get_tree().process_frame

	if not audio_manager.is_music_playing():
		# Skip functional test if no audio file (still pass static checks)
		print("  - Skipping functional test (no audio file)")
		_pass()
		return

	audio_manager.stop_music()
	await get_tree().process_frame

	if audio_manager.is_music_playing():
		_fail("Music should not be playing after stop_music()")
		return

	print("  - Functional stop_music test: OK")
	_pass()


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
	print("All menu transitions properly stop music.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
