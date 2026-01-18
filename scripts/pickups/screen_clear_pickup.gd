extends BasePickup
class_name ScreenClearPickup
## Ghost wand pickup that clears all enemies on screen.
## When collected, damages all visible enemies.

## Damage dealt to each enemy (enough to kill most enemies)
const DAMAGE_PER_ENEMY: int = 10

## Sprite path for this pickup
const SPRITE_PATH: String = "res://assets/sprites/upgrade-ghost-wand-1.png"


## Called after base _ready() completes
func _pickup_ready() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(SPRITE_PATH)
		if texture:
			sprite.texture = texture


## Override collection behavior - clear all enemies on screen
func _on_collected(body: Node2D) -> void:
	_clear_all_enemies()

	collected.emit()
	_play_sfx("pickup_collect")
	_play_collect_animation()


## Find and damage all enemies on screen
func _clear_all_enemies() -> void:
	# Get all enemies in the enemy group
	var enemies = get_tree().get_nodes_in_group("enemy")

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		# Check if enemy is on screen (visible area)
		if _is_on_screen(enemy):
			# Deal damage to the enemy (high damage to kill most enemies instantly)
			if enemy.has_method("take_hit"):
				enemy.take_hit(DAMAGE_PER_ENEMY)


## Check if an enemy is within the visible screen area
func _is_on_screen(enemy: Node2D) -> bool:
	var margin = 100.0
	return enemy.position.x > -margin and enemy.position.x < _viewport_width + margin \
		and enemy.position.y > -margin and enemy.position.y < _viewport_height + margin
