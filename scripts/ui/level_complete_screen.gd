extends CanvasLayer
## Level complete screen that displays when the player finishes the level.
## Pauses the game tree when shown.


func _ready() -> void:
	# Start hidden
	visible = false
	# Set process mode to continue running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


## Show the level complete screen and pause the game
func show_level_complete() -> void:
	visible = true
	# Pause the game tree
	get_tree().paused = true


## Hide the level complete screen (for next level functionality, if implemented later)
func hide_level_complete() -> void:
	visible = false
	get_tree().paused = false
