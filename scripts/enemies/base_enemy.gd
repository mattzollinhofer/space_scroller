extends Area2D
class_name BaseEnemy
## Base enemy class with health system, collision detection, and destruction animation.
## Scrolls left with the world and damages player on contact.

## Health of the enemy
@export var health: int = 1:
	set(value):
		health = value
		if health <= 0:
			_on_health_depleted()

## Movement speed (matches world scroll speed)
var scroll_speed: float = 180.0

## Whether the enemy is currently being destroyed (prevents double-processing)
var _is_destroying: bool = false

## Tween for flash effect (to avoid overlapping tweens)
var _flash_tween: Tween = null

## Emitted when the enemy dies
signal died()

## Emitted when hit by projectile (audio placeholder hook)
signal hit_by_projectile()


func _ready() -> void:
	# Connect signal for collision detection with player (CharacterBody2D)
	body_entered.connect(_on_body_entered)
	# Connect signal for collision detection with projectiles (Area2D)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _is_destroying:
		return

	# Move enemy left at scroll speed
	position.x -= scroll_speed * delta

	# Despawn when off-screen (left edge)
	if position.x < -100:
		_despawn()


func _on_body_entered(body: Node2D) -> void:
	if _is_destroying:
		return

	# Check if it's the player
	if body.has_method("take_damage"):
		body.take_damage()
		# Enemy is destroyed on contact with player
		health = 0


func _on_area_entered(area: Area2D) -> void:
	if _is_destroying:
		return

	# Projectiles call take_hit on the enemy
	# (handled by projectile.gd calling our take_hit method)
	pass


## Called when hit by a projectile
func take_hit(damage: int) -> void:
	if _is_destroying:
		return

	# Emit signal for audio hook
	hit_by_projectile.emit()

	# Store health before damage to check if enemy survives
	var health_before = health

	# Reduce health
	health -= damage

	# Play red flash effect if enemy survived the hit (health > 0)
	if health > 0:
		_play_hit_flash()


## Plays a red flash effect when enemy takes damage but survives
func _play_hit_flash() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return

	# Kill any existing flash tween to prevent overlap
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	# Store original modulate
	var original_modulate: Color = sprite.modulate

	# Apply red tint (high red, low green/blue for damage feedback)
	sprite.modulate = Color(1.5, 0.3, 0.3, 1.0)

	# Create tween to restore original color
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", original_modulate, 0.12)


func _on_health_depleted() -> void:
	if _is_destroying:
		return
	_is_destroying = true

	# Kill flash tween if active
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	# Emit died signal before destruction
	died.emit()

	# Play destruction animation
	_play_destruction_animation()


func _play_destruction_animation() -> void:
	# Disable collision during animation
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Hide the enemy sprite
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false

	# Create explosion sprite
	var explosion_texture = load("res://assets/sprites/explosion.png")
	var explosion = Sprite2D.new()
	explosion.texture = explosion_texture
	explosion.scale = Vector2(2, 2)
	add_child(explosion)

	# Animate explosion: scale up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "scale", Vector2(4, 4), 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)

	# Queue free after animation completes
	tween.chain().tween_callback(queue_free)


func _despawn() -> void:
	queue_free()
