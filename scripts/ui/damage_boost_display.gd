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
	# Find the player in the scene tree
	var player = get_tree().root.get_node_or_null("Main/Player")
	if player:
		print("DamageBoostDisplay: Connected to player at Main/Player")
		# Connect to damage_boost_changed signal
		if player.has_signal("damage_boost_changed"):
			player.damage_boost_changed.connect(_update_display)
			print("DamageBoostDisplay: Connected to damage_boost_changed signal")
		# Get initial damage boost
		if player.has_method("get_damage_boost"):
			var initial = player.get_damage_boost()
			print("DamageBoostDisplay: Initial damage boost = %d" % initial)
			_update_display(initial)
	else:
		print("DamageBoostDisplay: Could not find player at Main/Player")


## Update the display based on current damage boost
func _update_display(boost: int) -> void:
	print("DamageBoostDisplay: _update_display called with boost = %d" % boost)
	if boost <= 0:
		visible = false
		print("DamageBoostDisplay: Hiding (boost <= 0)")
		return

	visible = true
	print("DamageBoostDisplay: Showing (boost > 0), visible = %s" % visible)

	# Update the label to show damage multiplier (base 1 + boost)
	var label = get_node_or_null("Container/Label")
	if label:
		label.text = "x%d" % (1 + boost)
		print("DamageBoostDisplay: Label set to %s" % label.text)
