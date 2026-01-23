extends CanvasLayer
## Displays when the player has piercing shots active.
## Shows a needle icon when piercing shots is active.
## Hidden when piercing shots is inactive.


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
		# Connect to piercing_shots_changed signal
		if player.has_signal("piercing_shots_changed"):
			player.piercing_shots_changed.connect(_update_display)
		# Get initial piercing shots state
		if player.has_method("is_piercing_shots_active"):
			_update_display(player.is_piercing_shots_active())


## Update the display based on current piercing shots state
func _update_display(active: bool) -> void:
	visible = active
