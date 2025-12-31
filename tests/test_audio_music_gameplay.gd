extends Node2D
## Integration test: Background music plays when entering main gameplay scene
## Run this scene to verify AudioManager plays music when gameplay starts.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var main: Node = null


func _ready() -> void:
	print("=== Test: Background Music on Gameplay ===")

	# Check if AudioManager autoload exists
	if not has_node("/root/AudioManager"):
		_fail("AudioManager autoload not found")
		return

	var audio_manager = get_node("/root/AudioManager")

	# Load and setup main scene to trigger gameplay
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	main = main_scene.instantiate()
	add_child(main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame

	# Check if music is playing
	if not audio_manager.has_method("is_music_playing"):
		_fail("AudioManager does not have 'is_music_playing' method")
		return

	if audio_manager.is_music_playing():
		print("Background music is playing")
		_pass()
	else:
		_fail("Background music is not playing after entering main scene")


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
	print("Background music plays when entering main gameplay scene.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
