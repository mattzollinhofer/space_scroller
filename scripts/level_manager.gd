extends Node
## Manages level progression, section tracking, and checkpoints.
## Loads level data from JSON and orchestrates spawners based on current section.

## Path to the level JSON file
@export var level_path: String = "res://levels/level_1.json"

## Reference to the scroll controller for progress tracking
@export var scroll_controller_path: NodePath

## Reference to the progress bar UI
@export var progress_bar_path: NodePath

## Signals
signal section_changed(section_index: int)
signal level_completed()

## Level data loaded from JSON
var _level_data: Dictionary = {}

## Total distance of the level in pixels
var _total_distance: float = 9000.0

## Reference to scroll controller
var _scroll_controller: Node = null

## Reference to progress bar
var _progress_bar: Node = null

## Current progress (0.0 to 1.0)
var _current_progress: float = 0.0


func _ready() -> void:
	_load_level_data()
	_setup_references()


func _load_level_data() -> void:
	var file = FileAccess.open(level_path, FileAccess.READ)
	if not file:
		push_warning("Could not load level data from: %s" % level_path)
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_warning("Failed to parse level JSON: %s" % json.get_error_message())
		return

	_level_data = json.data
	_total_distance = _level_data.get("total_distance", 9000.0)


func _setup_references() -> void:
	# Get scroll controller reference
	if not scroll_controller_path.is_empty():
		_scroll_controller = get_node_or_null(scroll_controller_path)

	# Try to find scroll controller automatically if not set
	if not _scroll_controller:
		_scroll_controller = get_tree().root.get_node_or_null("Main/ParallaxBackground")

	# Get progress bar reference
	if not progress_bar_path.is_empty():
		_progress_bar = get_node_or_null(progress_bar_path)

	# Try to find progress bar automatically if not set
	if not _progress_bar:
		_progress_bar = get_tree().root.get_node_or_null("Main/ProgressBar")


func _process(_delta: float) -> void:
	_update_progress()


func _update_progress() -> void:
	if not _scroll_controller:
		return

	# scroll_offset.x is negative as it scrolls left, so we use the absolute value
	var distance_traveled = abs(_scroll_controller.scroll_offset.x)
	_current_progress = clamp(distance_traveled / _total_distance, 0.0, 1.0)

	# Update progress bar
	if _progress_bar and _progress_bar.has_method("set_progress"):
		_progress_bar.set_progress(_current_progress)


## Get current progress as a percentage (0.0 to 1.0)
func get_progress() -> float:
	return _current_progress


## Get total distance of the level
func get_total_distance() -> float:
	return _total_distance
