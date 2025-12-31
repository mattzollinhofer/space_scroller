extends Node2D
## Draws a star field background with random small dots.
## Uses _draw() for placeholder visuals - will be replaced with real artwork later.
## Supports theme presets for different level backgrounds.

## Number of stars to draw
@export var star_count: int = 150

## Minimum star size in pixels
@export var min_star_size: float = 2.0

## Maximum star size in pixels
@export var max_star_size: float = 4.0

## Random seed for consistent star placement
@export var random_seed: int = 12345

## Theme preset: "default", "inner_solar", "outer_solar"
@export var theme_preset: String = "default"

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
	match theme_preset:
		"inner_solar":
			return _get_inner_solar_star_color(rng)
		"outer_solar":
			return _get_outer_solar_star_color(rng)
		_:
			return _get_default_star_color(rng)


func _get_default_star_color(rng: RandomNumberGenerator) -> Color:
	# Mix of white and pale yellow stars
	var brightness = rng.randf_range(0.7, 1.0)
	if rng.randf() < 0.3:
		# Pale yellow star
		return Color(brightness, brightness * 0.95, brightness * 0.8)
	else:
		# White star
		return Color(brightness, brightness, brightness)


func _get_inner_solar_star_color(rng: RandomNumberGenerator) -> Color:
	# Warm colors: orange, yellow, red-orange stars for inner solar system
	var brightness = rng.randf_range(0.7, 1.0)
	var color_choice = rng.randi() % 4

	match color_choice:
		0:
			# Orange star
			return Color(brightness, brightness * 0.6, brightness * 0.2)
		1:
			# Yellow-orange star
			return Color(brightness, brightness * 0.8, brightness * 0.3)
		2:
			# Red-orange star
			return Color(brightness, brightness * 0.4, brightness * 0.2)
		_:
			# Warm yellow star
			return Color(brightness, brightness * 0.9, brightness * 0.5)


func _get_outer_solar_star_color(rng: RandomNumberGenerator) -> Color:
	# Cool colors: blue, cyan, white stars for outer solar system
	var brightness = rng.randf_range(0.7, 1.0)
	var color_choice = rng.randi() % 4

	match color_choice:
		0:
			# Ice blue star
			return Color(brightness * 0.7, brightness * 0.85, brightness)
		1:
			# Cyan star
			return Color(brightness * 0.6, brightness * 0.9, brightness)
		2:
			# Cool white star
			return Color(brightness * 0.9, brightness * 0.95, brightness)
		_:
			# Pale blue star
			return Color(brightness * 0.8, brightness * 0.9, brightness)


## Set the theme and regenerate stars
func set_theme(preset: String) -> void:
	theme_preset = preset
	_generate_stars()
	queue_redraw()


func _draw() -> void:
	for star in _stars:
		draw_circle(star.position, star.size, star.color)
