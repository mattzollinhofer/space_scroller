extends CanvasLayer
## Progress bar UI that displays level progress (0-100%).
## Shows a horizontal bar that fills from left to right.
## Also displays the current level number.

## Width of the progress bar in pixels
@export var bar_width: float = 496.0

## Current progress value (0.0 to 1.0)
var _progress: float = 0.0

## Current level number
var _current_level: int = 1

## Reference to the fill bar
@onready var _fill: ColorRect = $Container/Fill

## Reference to the level label
@onready var _level_label: Label = $Container/LevelLabel


func _ready() -> void:
	# Start visible, show during gameplay
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_fill()
	_update_level_label()


## Set the progress value (0.0 to 1.0)
func set_progress(percent: float) -> void:
	_progress = clamp(percent, 0.0, 1.0)
	_update_fill()


## Get the current progress value (0.0 to 1.0)
func get_progress() -> float:
	return _progress


## Set the current level number
func set_level(level: int) -> void:
	_current_level = max(1, level)
	_update_level_label()


## Get the current level number
func get_level() -> int:
	return _current_level


func _update_fill() -> void:
	if not _fill:
		return

	# Calculate fill width based on progress
	var fill_width = bar_width * _progress

	# Update fill bar size (offset_right is relative to anchor point)
	# Background is -250 to +250 (500px), fill starts at -248 (with 2px margin)
	_fill.offset_right = -248.0 + fill_width


func _update_level_label() -> void:
	if not _level_label:
		return

	_level_label.text = "Level %d" % _current_level
