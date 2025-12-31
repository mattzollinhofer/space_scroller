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
	if not _fill:
		return

	# Calculate fill percentage
	var fill_percent = get_fill_percent()

	# Fill bar: left margin at 2, max right at 298 (296px total width)
	var fill_left = 2.0
	var fill_max_width = 296.0
	var fill_width = fill_max_width * fill_percent

	# Update offset_right to shrink/grow the fill
	_fill.offset_right = fill_left + fill_width


## Hide the health bar
func hide_bar() -> void:
	visible = false


## Show the health bar
func show_bar() -> void:
	visible = true
