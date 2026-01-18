extends BasePickup
class_name PiercingShotPickup
## Needle pickup that grants temporary piercing shots.
## When collected, projectiles pass through enemies instead of stopping.

## Duration of piercing shot effect in seconds
const PIERCING_DURATION: float = 10.0

## Sprite path for this pickup
const SPRITE_PATH: String = "res://assets/sprites/special-needle-1.png"


## Called after base _ready() completes
func _pickup_ready() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(SPRITE_PATH)
		if texture:
			sprite.texture = texture


## Override collection behavior - grant piercing shots to player
func _on_collected(body: Node2D) -> void:
	if body.has_method("activate_piercing_shots"):
		body.activate_piercing_shots(PIERCING_DURATION)

	collected.emit()
	_play_sfx("pickup_collect")
	_play_collect_animation()
