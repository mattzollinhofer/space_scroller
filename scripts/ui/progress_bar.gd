extends CanvasLayer
## Progress bar UI that displays level progress (0-100%).
## Shows a horizontal bar that fills from left to right.

## Width of the progress bar in pixels
@export var bar_width: float = 496.0

## Current progress value (0.0 to 1.0)
var _progress: float = 0.0

## Reference to the fill bar
@onready var _fill: ColorRect = $Container/Fill


func _ready() -> void:
	# Start hidden, only show during gameplay
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_fill()


## Set the progress value (0.0 to 1.0)
func set_progress(percent: float) -> void:
	_progress = clamp(percent, 0.0, 1.0)
	_update_fill()


## Get the current progress value (0.0 to 1.0)
func get_progress() -> float:
	return _progress


func _update_fill() -> void:
	if not _fill:
		return

	# Calculate fill width based on progress
	var fill_width = bar_width * _progress

	# Update fill bar size (offset_right is relative to anchor point)
	# Background is -250 to +250 (500px), fill starts at -248 (with 2px margin)
	_fill.offset_right = -248.0 + fill_width
