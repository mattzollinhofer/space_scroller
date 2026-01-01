extends CanvasLayer
## ScreenEffects autoload - provides screen shake, flash, and time freeze effects.
## Add as autoload to use globally: ScreenEffects.life_lost_effect()

## Shake parameters
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _original_offset: Vector2 = Vector2.ZERO

## Reference to the flash overlay
var _flash_overlay: ColorRect = null

## Reference to the container we shake
var _shake_target: Node2D = null


func _ready() -> void:
	layer = 100  # Always on top
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process even when paused/frozen

	# Create the flash overlay
	_create_flash_overlay()


func _create_flash_overlay() -> void:
	var overlay = ColorRect.new()
	overlay.name = "FlashOverlay"
	overlay.color = Color(1, 0, 0, 0)  # Red, fully transparent
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	_flash_overlay = overlay


func _process(delta: float) -> void:
	# Handle screen shake
	if _shake_timer > 0:
		_shake_timer -= delta
		if _shake_target:
			var shake_offset = Vector2(
				randf_range(-_shake_intensity, _shake_intensity),
				randf_range(-_shake_intensity, _shake_intensity)
			)
			_shake_target.position = _original_offset + shake_offset

		if _shake_timer <= 0:
			_end_shake()


## Combined effect for losing a life - arcade classic feel
func life_lost_effect() -> void:
	# All three effects together
	time_freeze(0.5)
	screen_shake(20.0, 0.4)
	red_flash(0.5)


## Shake the screen
func screen_shake(intensity: float = 15.0, duration: float = 0.3) -> void:
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration

	# Find something to shake - prefer the Main node
	if not _shake_target:
		_shake_target = get_tree().root.get_node_or_null("Main")

	if _shake_target:
		_original_offset = _shake_target.position


func _end_shake() -> void:
	if _shake_target:
		_shake_target.position = _original_offset
	_shake_intensity = 0.0
	_shake_timer = 0.0


## Flash the screen red
func red_flash(duration: float = 0.3) -> void:
	if not _flash_overlay:
		return

	# Flash in
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)  # Process during time freeze
	_flash_overlay.color = Color(1, 0, 0, 0.5)  # Red at 50% opacity
	tween.tween_property(_flash_overlay, "color:a", 0.0, duration).set_ease(Tween.EASE_OUT)


## Briefly freeze time
func time_freeze(duration: float = 0.15) -> void:
	Engine.time_scale = 0.0

	# Use a timer that ignores time scale
	var timer = get_tree().create_timer(duration, true, false, true)  # process_always = true
	timer.timeout.connect(_unfreeze)


func _unfreeze() -> void:
	Engine.time_scale = 1.0
