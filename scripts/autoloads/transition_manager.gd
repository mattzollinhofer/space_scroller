extends CanvasLayer
## Manages smooth transitions between screens using fade effects.
## Provides fade_out(), fade_in(), and transition_to_scene() methods.
## Registered as autoload to be accessible from any scene.

## Duration of fade transitions in seconds
const FADE_DURATION: float = 0.3

## The fade overlay ColorRect (created dynamically)
var _fade_overlay: ColorRect = null

## Current tween for fade animations
var _current_tween: Tween = null


func _ready() -> void:
	# Set to highest layer so fade is always on top
	layer = 100
	# Always process so transitions work even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create the fade overlay
	_create_fade_overlay()


## Create the full-screen fade overlay
func _create_fade_overlay() -> void:
	if _fade_overlay:
		return

	_fade_overlay = ColorRect.new()
	_fade_overlay.name = "FadeOverlay"
	# Full screen coverage
	_fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_overlay.anchor_right = 1.0
	_fade_overlay.anchor_bottom = 1.0
	# Black color, starts fully transparent
	_fade_overlay.color = Color(0, 0, 0, 0)
	# Don't block input when transparent
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_overlay)


## Fade out (screen goes black)
## alpha 0 -> 1 over FADE_DURATION
func fade_out() -> void:
	_stop_current_tween()
	_fade_overlay.color.a = 0.0
	_current_tween = create_tween()
	_current_tween.tween_property(_fade_overlay, "color:a", 1.0, FADE_DURATION)


## Fade in (black fades away)
## alpha 1 -> 0 over FADE_DURATION
func fade_in() -> void:
	_stop_current_tween()
	_fade_overlay.color.a = 1.0
	_current_tween = create_tween()
	_current_tween.tween_property(_fade_overlay, "color:a", 0.0, FADE_DURATION)


## Transition to a new scene with fade effect
## Fades out, changes scene, then fades in
func transition_to_scene(scene_path: String) -> void:
	# Start fade out
	fade_out()
	# Wait for fade to complete
	await _current_tween.finished
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	# Fade back in
	fade_in()


## Stop any currently running fade tween
func _stop_current_tween() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = null
