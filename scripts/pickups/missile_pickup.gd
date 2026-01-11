extends BasePickup
class_name MissilePickup
## Missile pickup that grants a damage boost when collected.
## Spawns from a random edge and zigzags across the screen.


## Override collection behavior - grant damage boost to player
func _on_collected(body: Node2D) -> void:
	if body.has_method("add_damage_boost"):
		body.add_damage_boost()
		collected.emit()
		_play_sfx("pickup_collect")
		_play_collect_animation()
