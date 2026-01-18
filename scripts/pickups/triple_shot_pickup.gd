extends BasePickup
class_name TripleShotPickup
## Sword pickup that grants permanent triple shot attack until life lost.
## When collected, player fires 3 projectiles at once instead of 1.

## Sprite path for this pickup
const SPRITE_PATH: String = "res://assets/sprites/sword-pickup-1.png"


## Called after base _ready() completes
func _pickup_ready() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(SPRITE_PATH)
		if texture:
			sprite.texture = texture


## Override collection behavior - grant triple shot to player
func _on_collected(body: Node2D) -> void:
	if body.has_method("activate_triple_shot"):
		body.activate_triple_shot()

	collected.emit()
	_play_sfx("pickup_collect")
	_play_collect_animation()
