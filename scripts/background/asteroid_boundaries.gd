extends Node2D
## Draws rocky asteroid belt strips at the top and bottom screen edges.
## Uses _draw() for placeholder visuals - will be replaced with real artwork later.

## Height of the asteroid belt strips in pixels
@export var boundary_height: float = 80.0

## Number of asteroid shapes per strip (per viewport width)
@export var asteroid_count: int = 25

## Random seed for consistent asteroid placement
@export var random_seed: int = 11111

## Internal storage for asteroid data (generated once)
var _top_asteroids: Array = []
var _bottom_asteroids: Array = []

## Viewport dimensions
var _viewport_width: float = 0.0
var _viewport_height: float = 0.0
var _draw_width: float = 0.0


func _ready() -> void:
	# Get viewport size
	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	_viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	_draw_width = _viewport_width * 2  # Double for mirroring

	# Generate asteroids with consistent random seed
	_generate_asteroids()


func _generate_asteroids() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed

	_top_asteroids.clear()
	_bottom_asteroids.clear()

	# Generate top boundary asteroids
	for i in range(asteroid_count * 2):  # Double for mirroring
		var asteroid = _create_asteroid(rng, 0.0, boundary_height)
		asteroid.position.x = rng.randf() * _draw_width
		_top_asteroids.append(asteroid)

	# Generate bottom boundary asteroids
	var bottom_y = _viewport_height - boundary_height
	for i in range(asteroid_count * 2):  # Double for mirroring
		var asteroid = _create_asteroid(rng, bottom_y, _viewport_height)
		asteroid.position.x = rng.randf() * _draw_width
		_bottom_asteroids.append(asteroid)


func _create_asteroid(rng: RandomNumberGenerator, min_y: float, max_y: float) -> Dictionary:
	var size = rng.randf_range(20.0, 50.0)
	return {
		"position": Vector2(0, rng.randf_range(min_y, max_y)),
		"size": size,
		"color": _get_asteroid_color(rng),
		"rotation": rng.randf() * TAU,
		"vertices": _generate_asteroid_vertices(rng, size)
	}


func _get_asteroid_color(rng: RandomNumberGenerator) -> Color:
	# Rocky browns and grays
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


func _generate_asteroid_vertices(rng: RandomNumberGenerator, size: float) -> PackedVector2Array:
	# Generate irregular polygon vertices for asteroid shape
	var vertices = PackedVector2Array()
	var num_vertices = rng.randi_range(5, 8)

	for i in range(num_vertices):
		var angle = (float(i) / num_vertices) * TAU
		var radius = size * rng.randf_range(0.6, 1.0)
		vertices.append(Vector2(cos(angle), sin(angle)) * radius)

	return vertices


func _draw() -> void:
	# Draw background fill for boundaries to ensure no gaps
	draw_rect(Rect2(0, 0, _draw_width, boundary_height), Color(0.15, 0.12, 0.1))
	draw_rect(Rect2(0, _viewport_height - boundary_height, _draw_width, boundary_height), Color(0.15, 0.12, 0.1))

	# Draw top boundary asteroids
	for asteroid in _top_asteroids:
		_draw_asteroid(asteroid)

	# Draw bottom boundary asteroids
	for asteroid in _bottom_asteroids:
		_draw_asteroid(asteroid)


func _draw_asteroid(asteroid: Dictionary) -> void:
	var pos = asteroid.position
	var vertices = asteroid.vertices as PackedVector2Array
	var rotated_vertices = PackedVector2Array()

	# Rotate and translate vertices
	for v in vertices:
		rotated_vertices.append(pos + v.rotated(asteroid.rotation))

	# Draw the asteroid polygon
	draw_colored_polygon(rotated_vertices, asteroid.color)

	# Draw a slightly darker outline for depth
	var outline_color = asteroid.color.darkened(0.3)
	for i in range(rotated_vertices.size()):
		var start = rotated_vertices[i]
		var end = rotated_vertices[(i + 1) % rotated_vertices.size()]
		draw_line(start, end, outline_color, 2.0)
