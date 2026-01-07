extends Node2D
## Animated space background for menu screens.
## Draws stars and nebulae with a gentle scrolling animation.

## Scroll speed in pixels per second (slower than gameplay for ambiance)
@export var scroll_speed: float = 30.0

## Star settings
@export var star_count: int = 120
@export var min_star_size: float = 1.5
@export var max_star_size: float = 3.5

## Nebula settings
@export var nebula_count: int = 6
@export var min_nebula_size: float = 150.0
@export var max_nebula_size: float = 350.0

## Random seeds for consistent placement
@export var star_seed: int = 99999
@export var nebula_seed: int = 88888

## Internal data
var _stars: Array = []
var _nebulae: Array = []
var _scroll_offset: float = 0.0
var _draw_width: float = 0.0
var _draw_height: float = 0.0


func _ready() -> void:
	_draw_width = ProjectSettings.get_setting("display/window/size/viewport_width") * 2
	_draw_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	_generate_stars()
	_generate_nebulae()


func _process(delta: float) -> void:
	_scroll_offset -= scroll_speed * delta
	# Wrap around when we've scrolled one viewport width
	if _scroll_offset < -_draw_width / 2:
		_scroll_offset += _draw_width / 2
	queue_redraw()


func _generate_stars() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = star_seed
	_stars.clear()

	for i in range(star_count):
		var star = {
			"position": Vector2(rng.randf() * _draw_width, rng.randf() * _draw_height),
			"size": rng.randf_range(min_star_size, max_star_size),
			"color": _get_star_color(rng),
			"twinkle_offset": rng.randf() * TAU,  # Random phase for twinkle
			"twinkle_speed": rng.randf_range(1.5, 3.0)  # Twinkle frequency
		}
		_stars.append(star)


func _get_star_color(rng: RandomNumberGenerator) -> Color:
	var brightness = rng.randf_range(0.7, 1.0)
	var color_type = rng.randf()

	if color_type < 0.5:
		# White star
		return Color(brightness, brightness, brightness)
	elif color_type < 0.7:
		# Pale yellow star
		return Color(brightness, brightness * 0.95, brightness * 0.8)
	elif color_type < 0.85:
		# Pale blue star
		return Color(brightness * 0.8, brightness * 0.9, brightness)
	else:
		# Golden star
		return Color(brightness, brightness * 0.85, brightness * 0.5)


func _generate_nebulae() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = nebula_seed
	_nebulae.clear()

	for i in range(nebula_count):
		var nebula = {
			"position": Vector2(rng.randf() * _draw_width, rng.randf() * _draw_height),
			"size": rng.randf_range(min_nebula_size, max_nebula_size),
			"color": _get_nebula_color(rng)
		}
		_nebulae.append(nebula)


func _get_nebula_color(rng: RandomNumberGenerator) -> Color:
	var color_choice = rng.randi() % 4
	var alpha = rng.randf_range(0.12, 0.28)

	match color_choice:
		0:
			# Purple nebula
			return Color(0.5, 0.2, 0.7, alpha)
		1:
			# Blue nebula
			return Color(0.2, 0.4, 0.8, alpha)
		2:
			# Pink nebula
			return Color(0.8, 0.3, 0.5, alpha)
		_:
			# Teal nebula
			return Color(0.2, 0.6, 0.7, alpha)


func _draw() -> void:
	var time = Time.get_ticks_msec() / 1000.0

	# Draw nebulae first (behind stars)
	for nebula in _nebulae:
		var pos = nebula.position
		pos.x = fmod(pos.x + _scroll_offset + _draw_width, _draw_width)

		# Draw main nebula
		draw_circle(pos, nebula.size / 2.0, nebula.color)
		# Draw brighter core
		var core_color = nebula.color
		core_color.a = core_color.a * 1.3
		draw_circle(pos, nebula.size / 4.0, core_color)

	# Draw stars with twinkle effect
	for star in _stars:
		var pos = star.position
		pos.x = fmod(pos.x + _scroll_offset + _draw_width, _draw_width)

		# Subtle twinkle: vary brightness slightly over time
		var twinkle = 0.85 + 0.15 * sin(time * star.twinkle_speed + star.twinkle_offset)
		var color = star.color
		color.r *= twinkle
		color.g *= twinkle
		color.b *= twinkle

		draw_circle(pos, star.size, color)
