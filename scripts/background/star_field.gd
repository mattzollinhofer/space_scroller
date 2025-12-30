extends Node2D
## Draws a star field background with random small dots.
## Uses _draw() for placeholder visuals - will be replaced with real artwork later.

## Number of stars to draw
@export var star_count: int = 150

## Minimum star size in pixels
@export var min_star_size: float = 2.0

## Maximum star size in pixels
@export var max_star_size: float = 4.0

## Random seed for consistent star placement
@export var random_seed: int = 12345

## Internal storage for star data (generated once)
var _stars: Array = []

## Viewport size for drawing area (doubled for mirroring)
var _draw_width: float = 0.0
var _draw_height: float = 0.0


func _ready() -> void:
	# Get viewport size
	_draw_width = ProjectSettings.get_setting("display/window/size/viewport_width") * 2
	_draw_height = ProjectSettings.get_setting("display/window/size/viewport_height")

	# Generate stars with consistent random seed
	_generate_stars()


func _generate_stars() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed

	_stars.clear()

	for i in range(star_count):
		var star = {
			"position": Vector2(rng.randf() * _draw_width, rng.randf() * _draw_height),
			"size": rng.randf_range(min_star_size, max_star_size),
			"color": _get_star_color(rng)
		}
		_stars.append(star)


func _get_star_color(rng: RandomNumberGenerator) -> Color:
	# Mix of white and pale yellow stars
	var brightness = rng.randf_range(0.7, 1.0)
	if rng.randf() < 0.3:
		# Pale yellow star
		return Color(brightness, brightness * 0.95, brightness * 0.8)
	else:
		# White star
		return Color(brightness, brightness, brightness)


func _draw() -> void:
	for star in _stars:
		draw_circle(star.position, star.size, star.color)
