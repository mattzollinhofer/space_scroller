extends BasePickup
class_name RapidFirePickup
## Pizza cutter pickup that grants temporary rapid fire mode.
## When collected, greatly increases fire rate for a limited time.

## Duration of rapid fire effect in seconds
const RAPID_FIRE_DURATION: float = 8.0

## Sprite path for this pickup
const SPRITE_PATH: String = "res://assets/sprites/bonus-pizza-cutter-1.png"


## Called after base _ready() completes
func _pickup_ready() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(SPRITE_PATH)
		if texture:
			sprite.texture = texture


## Override collection behavior - grant rapid fire to player
func _on_collected(body: Node2D) -> void:
	if body.has_method("activate_rapid_fire"):
		body.activate_rapid_fire(RAPID_FIRE_DURATION)

	collected.emit()
	_play_sfx("pickup_collect")
	_play_collect_animation()
