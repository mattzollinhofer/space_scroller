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

## Emitted when the enemy dies
signal died()


func _ready() -> void:
	# Connect signal for collision detection
	body_entered.connect(_on_body_entered)


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


func _on_health_depleted() -> void:
	if _is_destroying:
		return
	_is_destroying = true

	# Emit died signal before destruction
	died.emit()

	# Play destruction animation
	_play_destruction_animation()


func _play_destruction_animation() -> void:
	# Disable collision during animation
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Create tween for scale down and fade out
	var tween = create_tween()
	tween.set_parallel(true)

	# Scale down to 0
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)

	# Queue free after animation completes
	tween.chain().tween_callback(queue_free)


func _despawn() -> void:
	queue_free()
