extends BasePickup
class_name StarPickup
## Star pickup that restores one health (heart) when collected.
## Spawns from a random edge and zigzags across the screen.


## Override collection behavior - restore health if not at max
func _on_collected(body: Node2D) -> void:
	if body.gain_health():
		collected.emit()
		_play_sfx("pickup_collect")
		_award_bonus_points()
		_spawn_floating_heart()
		_play_collect_animation()
	# If player is at max health, star passes through


func _award_bonus_points() -> void:
	# Award bonus points via ScoreManager autoload
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("award_ufo_friend_bonus"):
			score_manager.award_ufo_friend_bonus()


func _spawn_floating_heart() -> void:
	# Find the HealthDisplay and trigger floating heart animation
	var health_display = get_tree().root.get_node_or_null("Main/HealthDisplay")
	if health_display and health_display.has_method("spawn_floating_heart"):
		health_display.spawn_floating_heart(global_position)
