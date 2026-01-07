extends Control
## Main menu screen displayed when the game launches.
## Provides buttons to start gameplay, access character selection, level selection, and view high scores.


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


## Handle Play button pressed - start gameplay with transition
func _on_play_button_pressed() -> void:
	_play_sfx("button_click")
	# Clear carried-over state when starting a fresh game
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		game_state.clear_current_lives()
		game_state.clear_sidekick_state()
		game_state.set_selected_level(1)  # Reset to level 1
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/main.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")


## Handle Level Select button pressed - navigate to level selection screen
func _on_level_select_button_pressed() -> void:
	_play_sfx("button_click")
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/level_select.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/level_select.tscn")


## Handle Character Selection button pressed
func _on_character_select_button_pressed() -> void:
	_play_sfx("button_click")
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/character_selection.tscn")
	else:
		# Fallback to instant transition
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/character_selection.tscn")


## Handle High Scores button pressed (placeholder)
func _on_high_scores_button_pressed() -> void:
	_play_sfx("button_click")
	# Placeholder - awaiting Score System feature
	pass


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
