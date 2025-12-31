extends Node2D
## Integration test: Boss music crossfades when boss_spawned signal fires
## Verifies that AudioManager switches to boss-specific music when the boss spawns.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0


func _ready() -> void:
	print("=== Test: Boss Music Crossfade ===")

	# Check if AudioManager autoload exists
	if not has_node("/root/AudioManager"):
		_fail("AudioManager autoload not found")
		return

	var audio_manager = get_node("/root/AudioManager")

	# Verify AudioManager has required methods for boss music
	if not audio_manager.has_method("crossfade_to_boss_music"):
		_fail("AudioManager does not have 'crossfade_to_boss_music' method")
		return

	if not audio_manager.has_method("is_boss_music_playing"):
		_fail("AudioManager does not have 'is_boss_music_playing' method")
		return

	print("  - AudioManager has crossfade_to_boss_music method: OK")
	print("  - AudioManager has is_boss_music_playing method: OK")

	# Verify boss music tracks exist for all 3 levels (OGG or WAV)
	for level in [1, 2, 3]:
		var ogg_track = "res://assets/audio/music/boss_%d.ogg" % level
		var wav_track = "res://assets/audio/music/boss_%d.wav" % level

		if ResourceLoader.exists(ogg_track):
			print("  - Boss track exists: boss_%d.ogg" % level)
		elif ResourceLoader.exists(wav_track):
			print("  - Boss track exists: boss_%d.wav" % level)
		else:
			_fail("Boss music track not found for level %d (checked .ogg and .wav)" % level)
			return

	# Test 1: Verify LevelManager connects to AudioManager for boss_spawned
	var level_manager_script = load("res://scripts/level_manager.gd")
	if not level_manager_script:
		_fail("Could not load level_manager.gd")
		return

	var level_manager_source = level_manager_script.source_code
	# Check that boss_spawned triggers boss music (either in level_manager or audio_manager)
	if level_manager_source.find("crossfade_to_boss_music") != -1:
		print("  - level_manager.gd triggers crossfade_to_boss_music: OK")
	elif has_boss_music_connection_in_audio_manager():
		print("  - AudioManager connects to boss_spawned signal: OK")
	else:
		_fail("No connection between boss_spawned and crossfade_to_boss_music found")
		return

	# Test 2: Functional test - start regular music, then crossfade to boss music
	audio_manager.play_music()
	await get_tree().process_frame

	# Call crossfade to boss music for level 1
	audio_manager.crossfade_to_boss_music(1)

	# Wait for crossfade to complete (crossfade takes time)
	await get_tree().create_timer(1.5).timeout

	# Verify boss music is now playing
	if not audio_manager.is_boss_music_playing():
		_fail("Boss music should be playing after crossfade_to_boss_music(1)")
		return

	print("  - Boss music plays after crossfade: OK")

	# Test 3: Verify different levels get different boss tracks
	# Check that AudioManager loads boss tracks for levels 1, 2, 3 (via boss_%d pattern or literals)
	var audio_manager_script = load("res://scripts/autoloads/audio_manager.gd")
	if audio_manager_script:
		var audio_source = audio_manager_script.source_code
		# Check for either literal boss_1/2/3 or the boss_%d pattern with level iteration
		var has_boss_pattern = audio_source.find("boss_%d") != -1 or (audio_source.find("boss_1") != -1 and audio_source.find("boss_2") != -1 and audio_source.find("boss_3") != -1)
		var iterates_levels = audio_source.find("[1, 2, 3]") != -1 or audio_source.find("for level") != -1
		if has_boss_pattern and iterates_levels:
			print("  - AudioManager loads boss tracks for all 3 levels: OK")
		else:
			_fail("AudioManager should load boss tracks for levels 1, 2, and 3")
			return

	_pass()


func has_boss_music_connection_in_audio_manager() -> bool:
	## Check if AudioManager script connects to boss_spawned signal
	var audio_manager_script = load("res://scripts/autoloads/audio_manager.gd")
	if not audio_manager_script:
		return false
	var source = audio_manager_script.source_code
	return source.find("boss_spawned") != -1


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
	print("Boss music crossfades when boss spawns.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
