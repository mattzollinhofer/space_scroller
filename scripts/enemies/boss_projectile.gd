extends Area2D
## Projectile fired by boss. Travels left and damages player on contact.
## Despawns when leaving the left edge of the screen.

## Movement speed in pixels per second
@export var speed: float = 750.0

## Direction of movement (normalized vector)
var direction: Vector2 = Vector2(-1, 0)

## Left edge for despawn check
var _despawn_x: float = -100.0


func _ready() -> void:
	# Connect body_entered signal for player collision (CharacterBody2D)
	body_entered.connect(_on_body_entered)
	# Connect area_entered signal for asteroid collision (Area2D)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	# Move in the specified direction
	position += direction * speed * delta

	# Despawn when off left edge
	if position.x < _despawn_x:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body.has_method("take_damage"):
		body.take_damage()
		# Destroy projectile on hit
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Check if it's an asteroid (in asteroids group)
	if area.is_in_group("asteroids") and area.has_method("take_hit"):
		area.take_hit(1)
		queue_free()


## Set the movement direction (for spread patterns)
func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()


## Set the projectile color (for themed attacks)
func set_color(color: Color) -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = color
