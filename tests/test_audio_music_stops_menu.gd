extends Node2D
## Integration test: Music stops when transitioning to main menu
## Run this scene to verify AudioManager stops music when returning to menu.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var main: Node = null


func _ready() -> void:
	print("=== Test: Music Stops When Returning to Menu ===")

	# Check if AudioManager autoload exists
	if not has_node("/root/AudioManager"):
		_fail("AudioManager autoload not found")
		return

	var audio_manager = get_node("/root/AudioManager")

	# First verify AudioManager has required methods
	if not audio_manager.has_method("play_music"):
		_fail("AudioManager does not have 'play_music' method")
		return

	if not audio_manager.has_method("stop_music"):
		_fail("AudioManager does not have 'stop_music' method")
		return

	if not audio_manager.has_method("is_music_playing"):
		_fail("AudioManager does not have 'is_music_playing' method")
		return

	# Start music to simulate gameplay state
	audio_manager.play_music()

	await get_tree().process_frame

	# Verify music is playing
	if not audio_manager.is_music_playing():
		_fail("Music should be playing before testing stop_music")
		return

	print("Music confirmed playing, now calling stop_music...")

	# Call stop_music (simulating transition to menu)
	audio_manager.stop_music()

	await get_tree().process_frame

	# Verify music is not playing
	if audio_manager.is_music_playing():
		_fail("Music should not be playing after stop_music() is called")
		return

	print("Music confirmed stopped after stop_music() call")
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
	print("Music stops when stop_music() is called (menu transition).")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
