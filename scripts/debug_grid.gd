extends Node2D
## Debug grid to visualize world coordinates and movement

@export var grid_size: int = 200
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var label_color: Color = Color(1, 1, 1, 0.7)

func _draw() -> void:
	var viewport_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)

	# Draw vertical lines
	for x in range(0, int(viewport_size.x) + grid_size, grid_size):
		draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), grid_color, 2.0)
		# Draw x coordinate label
		draw_string(ThemeDB.fallback_font, Vector2(x + 5, 20), str(x), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, label_color)

	# Draw horizontal lines
	for y in range(0, int(viewport_size.y) + grid_size, grid_size):
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), grid_color, 2.0)
		# Draw y coordinate label
		draw_string(ThemeDB.fallback_font, Vector2(5, y + 20), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, label_color)

	# Draw border around viewport
	draw_rect(Rect2(0, 0, viewport_size.x, viewport_size.y), Color.RED, false, 3.0)

	# Draw center crosshair
	var center = viewport_size / 2
	draw_line(Vector2(center.x - 50, center.y), Vector2(center.x + 50, center.y), Color.YELLOW, 2.0)
	draw_line(Vector2(center.x, center.y - 50), Vector2(center.x, center.y + 50), Color.YELLOW, 2.0)
	draw_string(ThemeDB.fallback_font, center + Vector2(10, -10), "CENTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.YELLOW)
