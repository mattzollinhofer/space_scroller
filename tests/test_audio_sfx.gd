extends Node2D
## Integration test: SFX infrastructure exists and plays sounds
## Verifies AudioManager has play_sfx method and SFX files exist.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Sound Effects Infrastructure ===")

	# Check if AudioManager autoload exists
	if not has_node("/root/AudioManager"):
		_fail("AudioManager autoload not found")
		return

	var audio_manager = get_node("/root/AudioManager")

	# Verify AudioManager has play_sfx method
	if not audio_manager.has_method("play_sfx"):
		_fail("AudioManager does not have 'play_sfx' method")
		return

	print("  - AudioManager has play_sfx method: OK")

	# Verify high-priority SFX files exist (maps name -> category/name)
	var high_priority_sfx = {
		"player_shoot": "weapons/attack-missile-1",
		"enemy_hit": "explosions/explosion-2",
		"enemy_destroyed": "explosions/explosion-1",
		"player_damage": "explosions/explosion-2",
		"player_death": "explosions/explosion-1"
	}

	for sfx_name in high_priority_sfx:
		var sfx_path = high_priority_sfx[sfx_name]
		var wav_path = "res://assets/audio/sfx/%s.wav" % sfx_path
		var ogg_path = "res://assets/audio/sfx/%s.ogg" % sfx_path

		if ResourceLoader.exists(wav_path):
			print("  - SFX exists: %s.wav" % sfx_path)
		elif ResourceLoader.exists(ogg_path):
			print("  - SFX exists: %s.ogg" % sfx_path)
		else:
			_fail("SFX file not found: %s (checked .wav and .ogg)" % sfx_path)
			return

	# Verify player.gd has SFX calls
	var player_script = load("res://scripts/player.gd")
	if player_script:
		var source = player_script.source_code
		if source.find("play_sfx") == -1:
			_fail("player.gd should call play_sfx for sound effects")
			return
		print("  - player.gd has play_sfx calls: OK")

	# Verify base_enemy.gd has SFX calls
	var enemy_script = load("res://scripts/enemies/base_enemy.gd")
	if enemy_script:
		var source = enemy_script.source_code
		if source.find("play_sfx") == -1:
			_fail("base_enemy.gd should call play_sfx for sound effects")
			return
		print("  - base_enemy.gd has play_sfx calls: OK")

	# Functional test: call play_sfx (should not error)
	audio_manager.play_sfx("player_shoot")
	await get_tree().process_frame
	print("  - play_sfx call executed without error: OK")

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("SFX infrastructure is set up correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
