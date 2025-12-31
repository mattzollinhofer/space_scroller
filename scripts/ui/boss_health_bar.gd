extends CanvasLayer
## Boss health bar UI that displays boss health.
## Shows a horizontal bar that depletes from right to left as boss takes damage.
## Positioned in bottom-right corner of screen.

## Width of the health bar in pixels
@export var bar_width: float = 300.0

## Current health value
var _current_health: int = 13

## Maximum health value
var _max_health: int = 13

## Reference to the fill bar
@onready var _fill: ColorRect = $Container/Fill

## Reference to the background bar (for calculating fill width)
@onready var _background: ColorRect = $Container/Background


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_fill()


## Set the health values and update the bar
func set_health(current: int, max_health: int) -> void:
	_current_health = current
	_max_health = max_health
	_update_fill()


## Get the current fill percentage (0.0 to 1.0)
func get_fill_percent() -> float:
	if _max_health <= 0:
		return 0.0
	return float(_current_health) / float(_max_health)


func _update_fill() -> void:
	if not _fill or not _background:
		return

	# Calculate fill percentage
	var fill_percent = get_fill_percent()

	# Get background dimensions for reference
	var bg_width = _background.offset_right - _background.offset_left
	if bg_width <= 0:
		bg_width = bar_width

	# Fill from left, so we adjust offset_right based on fill percentage
	# offset_left stays at 0, offset_right moves based on health
	var fill_width = bg_width * fill_percent

	# The fill starts at offset_left = 0 (relative to anchor)
	# We only need to update offset_right to shrink/grow the fill
	_fill.offset_right = _fill.offset_left + fill_width - 4  # -4 for margin


## Hide the health bar
func hide_bar() -> void:
	visible = false


## Show the health bar
func show_bar() -> void:
	visible = true
