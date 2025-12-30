extends Node2D
## Draws small space debris particles for the nearest parallax layer.
## Uses _draw() for placeholder visuals - will be replaced with real artwork later.

## Number of debris particles to draw
@export var debris_count: int = 40

## Minimum debris size in pixels
@export var min_size: float = 8.0

## Maximum debris size in pixels
@export var max_size: float = 16.0

## Random seed for consistent debris placement
@export var random_seed: int = 98765

## Internal storage for debris data (generated once)
var _debris: Array = []

## Viewport size for drawing area (doubled for mirroring)
var _draw_width: float = 0.0
var _draw_height: float = 0.0


func _ready() -> void:
	# Get viewport size
	_draw_width = ProjectSettings.get_setting("display/window/size/viewport_width") * 2
	_draw_height = ProjectSettings.get_setting("display/window/size/viewport_height")

	# Generate debris with consistent random seed
	_generate_debris()


func _generate_debris() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed

	_debris.clear()

	for i in range(debris_count):
		var piece = {
			"position": Vector2(rng.randf() * _draw_width, rng.randf() * _draw_height),
			"size": rng.randf_range(min_size, max_size),
			"color": _get_debris_color(rng),
			"rotation": rng.randf() * TAU,
			"shape_type": rng.randi() % 3  # 0=triangle, 1=rect, 2=irregular
		}
		_debris.append(piece)


func _get_debris_color(rng: RandomNumberGenerator) -> Color:
	# Gray/brown tones for space debris
	var brightness = rng.randf_range(0.3, 0.6)
	var color_choice = rng.randi() % 3

	match color_choice:
		0:
			# Gray rock
			return Color(brightness, brightness, brightness)
		1:
			# Brown rock
			return Color(brightness * 1.2, brightness * 0.9, brightness * 0.6)
		2:
			# Dark gray
			return Color(brightness * 0.8, brightness * 0.8, brightness * 0.9)
		_:
			return Color(brightness, brightness, brightness)


func _draw() -> void:
	for piece in _debris:
		var pos = piece.position
		var size = piece.size
		var half_size = size / 2.0

		match piece.shape_type:
			0:
				# Triangle debris
				var points = PackedVector2Array([
					pos + Vector2(0, -half_size).rotated(piece.rotation),
					pos + Vector2(-half_size, half_size).rotated(piece.rotation),
					pos + Vector2(half_size, half_size).rotated(piece.rotation)
				])
				draw_colored_polygon(points, piece.color)
			1:
				# Rectangular debris
				var rect = Rect2(pos - Vector2(half_size, half_size * 0.6), Vector2(size, size * 0.6))
				draw_rect(rect, piece.color)
			2:
				# Irregular (pentagon-ish) debris
				var points = PackedVector2Array([
					pos + Vector2(0, -half_size).rotated(piece.rotation),
					pos + Vector2(half_size * 0.8, -half_size * 0.3).rotated(piece.rotation),
					pos + Vector2(half_size * 0.6, half_size * 0.7).rotated(piece.rotation),
					pos + Vector2(-half_size * 0.5, half_size * 0.6).rotated(piece.rotation),
					pos + Vector2(-half_size * 0.9, -half_size * 0.2).rotated(piece.rotation)
				])
				draw_colored_polygon(points, piece.color)
