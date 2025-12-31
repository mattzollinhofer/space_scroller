extends Node2D
## Draws semi-transparent nebula shapes for the middle parallax layer.
## Uses _draw() for placeholder visuals - will be replaced with real artwork later.
## Supports theme presets for different level backgrounds.

## Number of nebula shapes to draw
@export var nebula_count: int = 8

## Minimum nebula size (diameter) in pixels
@export var min_size: float = 100.0

## Maximum nebula size (diameter) in pixels
@export var max_size: float = 300.0

## Random seed for consistent nebula placement
@export var random_seed: int = 54321

## Theme preset: "default", "inner_solar", "outer_solar"
@export var theme_preset: String = "default"

## Internal storage for nebula data (generated once)
var _nebulae: Array = []

## Viewport size for drawing area (doubled for mirroring)
var _draw_width: float = 0.0
var _draw_height: float = 0.0


func _ready() -> void:
	# Get viewport size
	_draw_width = ProjectSettings.get_setting("display/window/size/viewport_width") * 2
	_draw_height = ProjectSettings.get_setting("display/window/size/viewport_height")

	# Generate nebulae with consistent random seed
	_generate_nebulae()


func _generate_nebulae() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed

	_nebulae.clear()

	for i in range(nebula_count):
		var nebula = {
			"position": Vector2(rng.randf() * _draw_width, rng.randf() * _draw_height),
			"size": rng.randf_range(min_size, max_size),
			"color": _get_nebula_color(rng)
		}
		_nebulae.append(nebula)


func _get_nebula_color(rng: RandomNumberGenerator) -> Color:
	match theme_preset:
		"inner_solar":
			return _get_inner_solar_nebula_color(rng)
		"outer_solar":
			return _get_outer_solar_nebula_color(rng)
		_:
			return _get_default_nebula_color(rng)


func _get_default_nebula_color(rng: RandomNumberGenerator) -> Color:
	# Semi-transparent purple, blue, or pink nebula colors
	var color_choice = rng.randi() % 3
	var alpha = rng.randf_range(0.15, 0.35)

	match color_choice:
		0:
			# Purple nebula
			return Color(0.6, 0.3, 0.8, alpha)
		1:
			# Blue nebula
			return Color(0.3, 0.5, 0.9, alpha)
		2:
			# Pink nebula
			return Color(0.9, 0.4, 0.6, alpha)
		_:
			return Color(0.6, 0.3, 0.8, alpha)


func _get_inner_solar_nebula_color(rng: RandomNumberGenerator) -> Color:
	# Warm red/orange/amber nebula colors for inner solar system
	var color_choice = rng.randi() % 4
	var alpha = rng.randf_range(0.15, 0.35)

	match color_choice:
		0:
			# Deep red nebula
			return Color(0.9, 0.25, 0.15, alpha)
		1:
			# Orange nebula
			return Color(0.95, 0.5, 0.2, alpha)
		2:
			# Amber/gold nebula
			return Color(0.9, 0.7, 0.2, alpha)
		_:
			# Crimson nebula
			return Color(0.85, 0.2, 0.25, alpha)


func _get_outer_solar_nebula_color(rng: RandomNumberGenerator) -> Color:
	# Cool blue/cyan/purple icy nebula colors for outer solar system
	var color_choice = rng.randi() % 4
	var alpha = rng.randf_range(0.15, 0.35)

	match color_choice:
		0:
			# Ice blue nebula
			return Color(0.4, 0.7, 0.95, alpha)
		1:
			# Cyan nebula
			return Color(0.3, 0.85, 0.9, alpha)
		2:
			# Pale purple/ice nebula
			return Color(0.6, 0.5, 0.9, alpha)
		_:
			# Deep blue nebula
			return Color(0.2, 0.4, 0.85, alpha)


## Set the theme and regenerate nebulae
func set_theme(preset: String) -> void:
	theme_preset = preset
	_generate_nebulae()
	queue_redraw()


func _draw() -> void:
	for nebula in _nebulae:
		# Draw main nebula circle
		draw_circle(nebula.position, nebula.size / 2.0, nebula.color)

		# Draw a smaller brighter core for depth effect
		var core_color = nebula.color
		core_color.a = core_color.a * 1.5
		draw_circle(nebula.position, nebula.size / 4.0, core_color)
