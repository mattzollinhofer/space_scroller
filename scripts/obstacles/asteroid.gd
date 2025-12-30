extends Area2D
## Procedurally drawn asteroid obstacle that can damage the player.
## Uses irregular polygon shapes with rocky brown/gray colors.

## Size of the asteroid in pixels (diameter)
@export var asteroid_size: float = 90.0

## Movement speed (matches world scroll speed)
var scroll_speed: float = 180.0

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
	# Brighter rocky browns and grays for better visibility
	var color_choice = rng.randi() % 4
	var brightness = rng.randf_range(0.45, 0.7)

	match color_choice:
		0:
			# Warm brown
			return Color(brightness * 1.3, brightness * 0.9, brightness * 0.6)
		1:
			# Light gray
			return Color(brightness * 1.1, brightness * 1.1, brightness * 1.1)
		2:
			# Reddish brown
			return Color(brightness * 1.4, brightness * 0.75, brightness * 0.55)
		3:
			# Blue-gray
			return Color(brightness * 0.85, brightness * 0.9, brightness * 1.0)
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

	# Draw outer glow effect (multiple layers, progressively larger and more transparent)
	var glow_color = _color.lightened(0.3)
	for glow_layer in range(3, 0, -1):
		var glow_scale = 1.0 + (glow_layer * 0.15)
		var glow_alpha = 0.15 / glow_layer
		var glow_vertices = PackedVector2Array()
		for v in rotated_vertices:
			glow_vertices.append(v * glow_scale)
		var layer_color = Color(glow_color.r, glow_color.g, glow_color.b, glow_alpha)
		draw_colored_polygon(glow_vertices, layer_color)

	# Draw the asteroid polygon
	draw_colored_polygon(rotated_vertices, _color)

	# Draw bright highlight outline for contrast
	var outline_color = _color.lightened(0.5)
	for i in range(rotated_vertices.size()):
		var start = rotated_vertices[i]
		var end = rotated_vertices[(i + 1) % rotated_vertices.size()]
		draw_line(start, end, outline_color, 3.0)

	# Draw inner dark edge for depth
	var inner_color = _color.darkened(0.4)
	var inner_scale = 0.85
	var inner_vertices = PackedVector2Array()
	for v in rotated_vertices:
		inner_vertices.append(v * inner_scale)
	for i in range(inner_vertices.size()):
		var start = inner_vertices[i]
		var end = inner_vertices[(i + 1) % inner_vertices.size()]
		draw_line(start, end, inner_color, 1.5)


func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body.has_method("take_damage"):
		body.take_damage()


func _despawn() -> void:
	queue_free()
