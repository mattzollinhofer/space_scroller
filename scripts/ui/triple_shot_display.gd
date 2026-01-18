extends CanvasLayer
## Displays when the player has triple shot active.
## Shows a sword icon when triple shot is active.
## Hidden when triple shot is inactive.


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Connect to player when ready (deferred to ensure player is initialized)
	call_deferred("_connect_to_player")


func _connect_to_player() -> void:
	# Find the player - try sibling first (when in main.tscn), then root path
	var player = get_parent().get_node_or_null("Player")
	if not player:
		player = get_tree().root.get_node_or_null("Main/Player")

	if player:
		# Connect to triple_shot_changed signal
		if player.has_signal("triple_shot_changed"):
			player.triple_shot_changed.connect(_update_display)
		# Get initial triple shot state
		if player.has_method("is_triple_shot_active"):
			_update_display(player.is_triple_shot_active())


## Update the display based on current triple shot state
func _update_display(active: bool) -> void:
	visible = active
