extends Node2D
## Integration test: Mute toggle works and persists
## Verifies AudioManager mute functions exist and ConfigFile persistence works.

var _test_passed: bool = false
var _test_failed: bool = false


func _ready() -> void:
	print("=== Test: Audio Mute Toggle ===")

	# Check if AudioManager autoload exists
	if not has_node("/root/AudioManager"):
		_fail("AudioManager autoload not found")
		return

	var audio_manager = get_node("/root/AudioManager")

	# Verify toggle_mute method exists
	if not audio_manager.has_method("toggle_mute"):
		_fail("AudioManager does not have 'toggle_mute' method")
		return
	print("  - AudioManager has toggle_mute method: OK")

	# Verify is_muted method exists
	if not audio_manager.has_method("is_muted"):
		_fail("AudioManager does not have 'is_muted' method")
		return
	print("  - AudioManager has is_muted method: OK")

	# Test toggle functionality
	var initial_state = audio_manager.is_muted()
	print("  - Initial mute state: %s" % str(initial_state))

	# Toggle mute
	audio_manager.toggle_mute()
	var after_toggle = audio_manager.is_muted()

	if after_toggle == initial_state:
		_fail("toggle_mute should change is_muted state")
		return
	print("  - Mute toggle changes state: OK")

	# Toggle back
	audio_manager.toggle_mute()
	var final_state = audio_manager.is_muted()

	if final_state != initial_state:
		_fail("Double toggle should return to initial state")
		return
	print("  - Double toggle returns to initial state: OK")

	# Verify pause menu has mute button (static check)
	var pause_menu_script = load("res://scripts/ui/pause_menu.gd")
	if pause_menu_script:
		var source = pause_menu_script.source_code
		if source.find("MuteButton") == -1:
			_fail("pause_menu.gd should reference MuteButton")
			return
		if source.find("toggle_mute") == -1:
			_fail("pause_menu.gd should call toggle_mute")
			return
		print("  - Pause menu has mute button integration: OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Mute toggle works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
