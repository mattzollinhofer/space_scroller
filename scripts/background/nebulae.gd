extends Node2D
## Draws semi-transparent nebula shapes for the middle parallax layer.
## Uses _draw() for placeholder visuals - will be replaced with real artwork later.

## Number of nebula shapes to draw
@export var nebula_count: int = 8

## Minimum nebula size (diameter) in pixels
@export var min_size: float = 100.0

## Maximum nebula size (diameter) in pixels
@export var max_size: float = 300.0

## Random seed for consistent nebula placement
@export var random_seed: int = 54321

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


func _draw() -> void:
	for nebula in _nebulae:
		# Draw main nebula circle
		draw_circle(nebula.position, nebula.size / 2.0, nebula.color)

		# Draw a smaller brighter core for depth effect
		var core_color = nebula.color
		core_color.a = core_color.a * 1.5
		draw_circle(nebula.position, nebula.size / 4.0, core_color)
