extends Control
## Main menu screen displayed when the game launches.
## Provides buttons to start gameplay, access character selection, and view high scores.


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


## Handle Play button pressed - start gameplay
func _on_play_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")


## Handle Character Selection button pressed
func _on_character_select_button_pressed() -> void:
	# TODO: Implement in Slice 3
	pass


## Handle High Scores button pressed (placeholder)
func _on_high_scores_button_pressed() -> void:
	# Placeholder - awaiting Score System feature
	pass
