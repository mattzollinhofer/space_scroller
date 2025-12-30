extends ParallaxBackground
## Controls the auto-scrolling of the parallax background.
## Scrolls the world leftward at a constant speed.

## Scroll speed in pixels per second
@export var scroll_speed: float = 120.0


func _process(delta: float) -> void:
	# Scroll the background leftward (decreasing scroll_offset.x moves layers left)
	scroll_offset.x -= scroll_speed * delta
