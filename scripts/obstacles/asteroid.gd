extends Area2D
## Asteroid obstacle that can damage the player.
## Uses sprite images with random size selection.

## Asteroid size variants
enum AsteroidSize { SMALL, REGULAR, LARGE }

## Which size asteroid to use (randomized by default)
@export var size_type: AsteroidSize = AsteroidSize.REGULAR

## Movement speed (matches world scroll speed)
var scroll_speed: float = 180.0

## Sprite textures for each size
var _textures: Dictionary = {
	AsteroidSize.SMALL: preload("res://assets/sprites/astroid-small.png"),
	AsteroidSize.REGULAR: preload("res://assets/sprites/astroid-regular.png"),
	AsteroidSize.LARGE: preload("res://assets/sprites/astroid-large.png")
}

## Collision radius for each size
var _collision_radii: Dictionary = {
	AsteroidSize.SMALL: 45.0,
	AsteroidSize.REGULAR: 60.0,
	AsteroidSize.LARGE: 90.0
}

## Sprite scale for each size
var _sprite_scales: Dictionary = {
	AsteroidSize.SMALL: Vector2(2.0, 2.0),
	AsteroidSize.REGULAR: Vector2(2.5, 2.5),
	AsteroidSize.LARGE: Vector2(3.5, 3.5)
}

## Sprite node
var _sprite: Sprite2D = null

## Glow sprite (behind main sprite)
var _glow: Sprite2D = null

## Reference to collision shape for size adjustment
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Randomize size if not explicitly set
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	size_type = rng.randi() % 3 as AsteroidSize

	# Create glow sprite (behind main sprite)
	_glow = Sprite2D.new()
	_glow.texture = _textures[size_type]
	_glow.scale = _sprite_scales[size_type] * 1.3
	_glow.modulate = Color(1.0, 0.7, 0.4, 0.5)  # Orange glow
	add_child(_glow)

	# Create and configure main sprite
	_sprite = Sprite2D.new()
	_sprite.texture = _textures[size_type]
	_sprite.scale = _sprite_scales[size_type]
	_sprite.modulate = Color(1.2, 1.1, 1.0)  # Slightly brighter
	add_child(_sprite)

	# Update collision shape to match sprite size
	_update_collision_shape()

	# Connect signal for collision detection
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# Move asteroid left at scroll speed
	position.x -= scroll_speed * delta

	# Despawn when off-screen (left edge)
	if position.x < -100:
		_despawn()


func _update_collision_shape() -> void:
	if _collision_shape:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = _collision_radii[size_type]
		_collision_shape.shape = circle_shape


func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body.has_method("take_damage"):
		body.take_damage()


func _despawn() -> void:
	queue_free()
