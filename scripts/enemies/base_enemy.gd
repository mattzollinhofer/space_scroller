extends Area2D
class_name BaseEnemy
## Base enemy class with health system, collision detection, and destruction animation.
## Moves in zigzag pattern while scrolling left. Damages player on contact.

## Health of the enemy
@export var health: int = 1:
	set(value):
		health = value
		if health <= 0:
			_on_health_depleted()

## Movement speed (matches world scroll speed)
var scroll_speed: float = 180.0

## Zigzag speed
@export var zigzag_speed: float = 120.0

## Zigzag angle range (degrees from horizontal, toward player)
## 90 = pure vertical, 45 = diagonal, 30 = more horizontal/aggressive
@export var zigzag_angle_min: float = 25.0
@export var zigzag_angle_max: float = 65.0

## Y bounds for zigzag movement
const Y_MIN: float = 140.0
const Y_MAX: float = 1396.0

## Current zigzag direction (1 or -1)
var _zigzag_direction: float = 1.0

## Randomized angle for this enemy's zigzag (radians)
var _zigzag_angle: float = 0.0

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
	# Randomize initial zigzag direction
	_zigzag_direction = 1.0 if randf() > 0.5 else -1.0
	# Randomize zigzag angle within range (convert to radians)
	var angle_deg = randf_range(zigzag_angle_min, zigzag_angle_max)
	_zigzag_angle = deg_to_rad(angle_deg)


func _process(delta: float) -> void:
	if _is_destroying:
		return

	# Move enemy left at scroll speed
	position.x -= scroll_speed * delta

	# Zigzag movement at randomized angle (diagonal toward player)
	# Angle is from horizontal, so cos = horizontal component, sin = vertical
	var zigzag_x = -cos(_zigzag_angle) * zigzag_speed * _zigzag_direction * delta
	var zigzag_y = sin(_zigzag_angle) * zigzag_speed * _zigzag_direction * delta
	position.x += zigzag_x
	position.y += zigzag_y

	# Bounce off Y bounds and reverse direction
	if position.y >= Y_MAX:
		position.y = Y_MAX
		_zigzag_direction = -1.0
	elif position.y <= Y_MIN:
		position.y = Y_MIN
		_zigzag_direction = 1.0

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


## Plays a hit effect when enemy takes damage but survives
func _play_hit_flash() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return

	# Kill any existing flash tween to prevent overlap
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	# Store original values
	var original_modulate: Color = sprite.modulate
	var original_scale: Vector2 = sprite.scale

	# Apply bright white flash and scale up
	sprite.modulate = Color(3.0, 3.0, 3.0, 1.0)
	sprite.scale = original_scale * 1.3

	# Create tween to restore original state
	_flash_tween = create_tween()
	_flash_tween.set_parallel(true)
	_flash_tween.tween_property(sprite, "modulate", original_modulate, 0.2).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(sprite, "scale", original_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


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
