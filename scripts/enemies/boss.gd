extends Area2D
class_name Boss
## Boss enemy with entrance animation, health system, and attack patterns.
## Spawns when level reaches 100% progress.

## Health of the boss
@export var health: int = 13:
	set(value):
		health = value
		health_changed.emit(health, _max_health)
		if health <= 0:
			_on_health_depleted()

## Maximum health (for UI percentage)
var _max_health: int = 13

## Whether the boss entrance animation has completed
var _entrance_complete: bool = false

## Whether the boss is currently being destroyed
var _is_destroying: bool = false

## Tween for flash effect
var _flash_tween: Tween = null

## Tween for entrance animation
var _entrance_tween: Tween = null

## Battle position (right third of screen)
var _battle_position: Vector2 = Vector2.ZERO

## Emitted when the boss is defeated
signal boss_defeated()

## Emitted when entrance animation completes
signal boss_entered()

## Emitted when health changes (for health bar UI)
signal health_changed(current: int, max_health: int)


func _ready() -> void:
	_max_health = health

	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Start playing idle animation
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


## Setup boss at spawn position and start entrance animation
func setup(spawn_position: Vector2, battle_position: Vector2) -> void:
	position = spawn_position
	_battle_position = battle_position
	_start_entrance_animation()


func _start_entrance_animation() -> void:
	_entrance_complete = false

	# Tween from spawn position to battle position
	_entrance_tween = create_tween()
	_entrance_tween.tween_property(self, "position", _battle_position, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_entrance_tween.tween_callback(_on_entrance_complete)


func _on_entrance_complete() -> void:
	_entrance_complete = true
	boss_entered.emit()


func _on_body_entered(body: Node2D) -> void:
	if _is_destroying:
		return

	# Check if it's the player
	if body.has_method("take_damage"):
		body.take_damage()


func _on_area_entered(_area: Area2D) -> void:
	if _is_destroying:
		return
	# Projectiles call take_hit on the boss
	pass


## Called when hit by a projectile
func take_hit(damage: int) -> void:
	if _is_destroying:
		return

	# Ignore damage during entrance animation
	if not _entrance_complete:
		return

	# Reduce health
	health -= damage

	# Play hit flash if still alive
	if health > 0:
		_play_hit_flash()


func _play_hit_flash() -> void:
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return

	# Kill any existing flash tween
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	# Store original values
	var original_modulate: Color = Color(1, 1, 1, 1)
	var original_scale: Vector2 = sprite.scale

	# Apply white flash and scale up
	sprite.modulate = Color(3.0, 3.0, 3.0, 1.0)
	sprite.scale = original_scale * 1.2

	# Restore original state
	_flash_tween = create_tween()
	_flash_tween.set_parallel(true)
	_flash_tween.tween_property(sprite, "modulate", original_modulate, 0.2).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(sprite, "scale", original_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _on_health_depleted() -> void:
	if _is_destroying:
		return
	_is_destroying = true

	# Kill tweens if active
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _entrance_tween and _entrance_tween.is_valid():
		_entrance_tween.kill()

	# Emit defeated signal
	boss_defeated.emit()

	# Play destruction animation (to be implemented in Slice 5)
	_play_destruction_animation()


func _play_destruction_animation() -> void:
	# Disable collision
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Hide sprite
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.visible = false

	# Create explosion (basic version, will be enhanced in Slice 5)
	var explosion_texture = load("res://assets/sprites/explosion.png")
	var explosion = Sprite2D.new()
	explosion.texture = explosion_texture
	explosion.scale = Vector2(4, 4)
	add_child(explosion)

	# Animate explosion
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "scale", Vector2(8, 8), 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
