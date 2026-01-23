extends BasePickup
class_name SpecialGunPickup
## Special gun pickup that grants permanent high-damage attack until life lost.
## When collected, player projectiles deal 5 damage and use special sprite.

## Sprite path for this pickup
const SPRITE_PATH: String = "res://assets/sprites/special-gun-pickup-1.png"


## Called after base _ready() completes
func _pickup_ready() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(SPRITE_PATH)
		if texture:
			sprite.texture = texture


## Override collection behavior - grant special gun to player
func _on_collected(body: Node2D) -> void:
	if body.has_method("activate_special_gun"):
		body.activate_special_gun()

	collected.emit()
	_play_sfx("pickup_collect")
	_play_collect_animation()
