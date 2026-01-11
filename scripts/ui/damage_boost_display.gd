extends CanvasLayer
## Displays the player's current damage boost level.
## Shows a fireball icon with "x2", "x3" etc when boost is active.
## Hidden when damage boost is 0.


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
		# Connect to damage_boost_changed signal
		if player.has_signal("damage_boost_changed"):
			player.damage_boost_changed.connect(_update_display)
		# Get initial damage boost
		if player.has_method("get_damage_boost"):
			_update_display(player.get_damage_boost())


## Update the display based on current damage boost
func _update_display(boost: int) -> void:
	if boost <= 0:
		visible = false
		return

	visible = true

	# Update the label to show damage multiplier (base 1 + boost)
	var label = get_node_or_null("Container/Label")
	if label:
		label.text = "x%d" % (1 + boost)
