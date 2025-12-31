extends Control
## Level selection screen allowing player to choose from available levels.
## Displays level buttons with locked/unlocked states based on progress.

## References to level buttons (set in _ready)
@onready var _level1_button: Button = $CenterContainer/VBoxContainer/LevelGrid/Level1Button
@onready var _back_button: Button = $CenterContainer/VBoxContainer/BackButton


func _ready() -> void:
	# Connect button signals
	_level1_button.pressed.connect(_on_level_selected.bind(1))
	_back_button.pressed.connect(_on_back_pressed)


## Handle level button pressed - start game with selected level
func _on_level_selected(level_number: int) -> void:
	# For now, just start main.tscn (Level 1)
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/main.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")


## Handle back button pressed - return to main menu with transition
func _on_back_pressed() -> void:
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")
