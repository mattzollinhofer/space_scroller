extends Area2D
## Projectile fired by boss. Travels left and damages player on contact.
## Despawns when leaving the left edge of the screen.

## Movement speed in pixels per second
@export var speed: float = 750.0

## Rotation speed in radians per second (0 = no rotation)
var rotation_speed: float = 0.0

## Direction of movement (normalized vector)
var direction: Vector2 = Vector2(-1, 0)

## Left edge for despawn check
var _despawn_x: float = -100.0

## Time alive (for spawn protection)
var _time_alive: float = 0.0

## Spawn protection duration (ignore asteroid collision)
const SPAWN_PROTECTION: float = 0.2


func _ready() -> void:
	# Connect body_entered signal for player collision (CharacterBody2D)
	body_entered.connect(_on_body_entered)
	# Connect area_entered signal for asteroid collision (Area2D)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	_time_alive += delta

	# Move in the specified direction
	position += direction * speed * delta

	# Rotate sprite if rotation speed is set
	if rotation_speed != 0.0:
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.rotation += rotation_speed * delta

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
	# Skip collision during spawn protection to avoid instant destruction
	if area.is_in_group("asteroids") and area.has_method("take_hit"):
		if _time_alive < SPAWN_PROTECTION:
			return
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


## Set the projectile texture (for boss-specific projectiles)
func set_texture(texture: Texture2D) -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.texture = texture
		# Reset modulate to white so custom textures show correctly
		sprite.modulate = Color(1, 1, 1, 1)


## Set the projectile scale (for larger projectiles like pepperoni)
func set_projectile_scale(scale_factor: float) -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.scale = Vector2(scale_factor, scale_factor)
	# Also scale the collision shape - make unique first to avoid shared resource issues
	var collision = get_node_or_null("CollisionShape2D")
	if collision and collision.shape:
		collision.shape = collision.shape.duplicate()
		if collision.shape is CircleShape2D:
			collision.shape.radius = collision.shape.radius * scale_factor
		elif collision.shape is RectangleShape2D:
			# Base size is 32x8, scale from that
			collision.shape.size = Vector2(32 * scale_factor, 8 * scale_factor)


## Set the rotation speed in radians per second (for swirl projectiles)
func set_rotation_speed(speed_radians: float) -> void:
	rotation_speed = speed_radians
