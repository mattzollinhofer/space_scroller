extends Area2D
## Procedurally drawn asteroid obstacle that can damage the player.
## Uses irregular polygon shapes with rocky brown/gray colors.

## Size of the asteroid in pixels (diameter)
@export var asteroid_size: float = 90.0

## Movement speed (matches world scroll speed)
var scroll_speed: float = 120.0

## Internal storage for visual data
var _vertices: PackedVector2Array = PackedVector2Array()
var _color: Color = Color.GRAY
var _rotation_angle: float = 0.0

## Reference to collision shape for size adjustment
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Generate asteroid visuals based on configured size
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	_generate_asteroid(rng)

	# Update collision shape to match visual size
	_update_collision_shape()

	# Connect signal for collision detection
	body_entered.connect(_on_body_entered)

	queue_redraw()


func _process(delta: float) -> void:
	# Move asteroid left at scroll speed
	position.x -= scroll_speed * delta

	# Despawn when off-screen (left edge)
	if position.x < -100:
		_despawn()


func _generate_asteroid(rng: RandomNumberGenerator) -> void:
	_vertices = _generate_asteroid_vertices(rng, asteroid_size / 2.0)
	_color = _get_asteroid_color(rng)
	_rotation_angle = rng.randf() * TAU


func _generate_asteroid_vertices(rng: RandomNumberGenerator, radius: float) -> PackedVector2Array:
	# Generate irregular polygon vertices for asteroid shape (5-8 vertices)
	var vertices = PackedVector2Array()
	var num_vertices = rng.randi_range(5, 8)

	for i in range(num_vertices):
		var angle = (float(i) / num_vertices) * TAU
		var r = radius * rng.randf_range(0.6, 1.0)
		vertices.append(Vector2(cos(angle), sin(angle)) * r)

	return vertices


func _get_asteroid_color(rng: RandomNumberGenerator) -> Color:
	# Rocky browns and grays (matching asteroid_boundaries.gd)
	var color_choice = rng.randi() % 4
	var brightness = rng.randf_range(0.25, 0.5)

	match color_choice:
		0:
			# Dark brown
			return Color(brightness * 1.3, brightness * 0.9, brightness * 0.6)
		1:
			# Gray
			return Color(brightness, brightness, brightness)
		2:
			# Reddish brown
			return Color(brightness * 1.4, brightness * 0.7, brightness * 0.5)
		3:
			# Dark gray
			return Color(brightness * 0.8, brightness * 0.85, brightness * 0.9)
		_:
			return Color(brightness, brightness, brightness)


func _update_collision_shape() -> void:
	if _collision_shape:
		# Create a new CircleShape2D with the correct radius
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = asteroid_size / 2.0
		_collision_shape.shape = circle_shape


func _draw() -> void:
	if _vertices.is_empty():
		return

	# Rotate vertices for drawing
	var rotated_vertices = PackedVector2Array()
	for v in _vertices:
		rotated_vertices.append(v.rotated(_rotation_angle))

	# Draw the asteroid polygon
	draw_colored_polygon(rotated_vertices, _color)

	# Draw a slightly darker outline for depth
	var outline_color = _color.darkened(0.3)
	for i in range(rotated_vertices.size()):
		var start = rotated_vertices[i]
		var end = rotated_vertices[(i + 1) % rotated_vertices.size()]
		draw_line(start, end, outline_color, 2.0)


func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body.has_method("take_damage"):
		body.take_damage()


func _despawn() -> void:
	queue_free()
