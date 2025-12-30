extends CanvasLayer
## Game over screen that displays when the player loses all lives.
## Pauses the game tree when shown.


func _ready() -> void:
	# Start hidden
	visible = false
	# Set process mode to continue running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


## Show the game over screen and pause the game
func show_game_over() -> void:
	visible = true
	# Pause the game tree
	get_tree().paused = true


## Hide the game over screen (for restart functionality, if implemented later)
func hide_game_over() -> void:
	visible = false
	get_tree().paused = false
