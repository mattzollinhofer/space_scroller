extends Node2D
## Integration test: Screen transitions have smooth fade effects
## Run this scene to verify TransitionManager functionality works end-to-end.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _frame_count: int = 0
var _max_frames: int = 300  # 5 seconds at 60fps


func _ready() -> void:
	print("=== Test: Screen Transitions ===")

	# Check if TransitionManager autoload exists
	if not has_node("/root/TransitionManager"):
		_fail("TransitionManager autoload not found - must be registered in project.godot")
		return

	var transition_manager = get_node("/root/TransitionManager")
	print("TransitionManager autoload found")

	# Check for required methods
	if not transition_manager.has_method("fade_out"):
		_fail("TransitionManager missing fade_out() method")
		return
	print("fade_out() method exists")

	if not transition_manager.has_method("fade_in"):
		_fail("TransitionManager missing fade_in() method")
		return
	print("fade_in() method exists")

	if not transition_manager.has_method("transition_to_scene"):
		_fail("TransitionManager missing transition_to_scene() method")
		return
	print("transition_to_scene() method exists")

	# Check that TransitionManager has a fade overlay
	var overlay = transition_manager.get_node_or_null("FadeOverlay")
	if not overlay:
		overlay = transition_manager.get_node_or_null("ColorRect")
	if not overlay:
		# Search children for a ColorRect
		for child in transition_manager.get_children():
			if child is ColorRect:
				overlay = child
				break

	if not overlay:
		_fail("TransitionManager missing fade overlay (ColorRect)")
		return
	print("Fade overlay found")

	# Verify overlay starts transparent (alpha = 0 or near 0)
	var initial_alpha = overlay.modulate.a if overlay is ColorRect else 0.0
	if overlay is ColorRect:
		initial_alpha = overlay.color.a

	# Some tolerance for floating point
	if initial_alpha > 0.1:
		_fail("Fade overlay should start transparent (alpha near 0), got: %s" % initial_alpha)
		return
	print("Fade overlay starts transparent: alpha = %s" % initial_alpha)

	# Test fade_out
	print("Testing fade_out()...")
	transition_manager.fade_out()

	# Wait for fade to complete then check alpha
	await get_tree().create_timer(0.5).timeout

	var after_fade_alpha = overlay.color.a if overlay is ColorRect else overlay.modulate.a
	if after_fade_alpha < 0.9:
		_fail("After fade_out, overlay alpha should be near 1.0, got: %s" % after_fade_alpha)
		return
	print("After fade_out, overlay alpha = %s (expected ~1.0)" % after_fade_alpha)

	# Test fade_in
	print("Testing fade_in()...")
	transition_manager.fade_in()

	# Wait for fade to complete then check alpha
	await get_tree().create_timer(0.5).timeout

	var after_fade_in_alpha = overlay.color.a if overlay is ColorRect else overlay.modulate.a
	if after_fade_in_alpha > 0.1:
		_fail("After fade_in, overlay alpha should be near 0.0, got: %s" % after_fade_in_alpha)
		return
	print("After fade_in, overlay alpha = %s (expected ~0.0)" % after_fade_in_alpha)

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("TransitionManager provides smooth fade transitions.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
