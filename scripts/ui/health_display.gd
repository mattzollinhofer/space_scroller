extends CanvasLayer
## Displays player health as heart icons.
## Shows filled hearts for remaining lives and faded hearts for lost lives.

## Reference to heart containers
@onready var _hearts: Array[TextureRect] = [
	$Container/Heart1,
	$Container/Heart2,
	$Container/Heart3
]

## Current displayed health
var _current_health: int = 3

## Heart texture for floating animation
var _heart_texture: Texture2D


func _ready() -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Cache the heart texture for floating hearts
	if _hearts[0]:
		_heart_texture = _hearts[0].texture
	_connect_to_player()


func _connect_to_player() -> void:
	# Find the player in the scene tree
	var player = get_tree().root.get_node_or_null("Main/Player")
	if player:
		if player.has_signal("lives_changed"):
			player.lives_changed.connect(_update_display)
		# Get initial lives
		if player.has_method("get_lives"):
			_update_display(player.get_lives())


## Update the heart display based on current lives
func _update_display(lives: int) -> void:
	_current_health = lives
	for i in range(_hearts.size()):
		if _hearts[i]:
			# Full opacity for filled hearts, faded for empty
			_hearts[i].modulate.a = 1.0 if i < lives else 0.3


## Spawn a floating heart that animates toward the health display
func spawn_floating_heart(from_position: Vector2) -> void:
	if not _heart_texture:
		return

	# Create a heart sprite - starts HUGE
	var heart = Sprite2D.new()
	heart.texture = _heart_texture
	heart.scale = Vector2(30.0, 30.0)  # Start HUGE
	heart.position = from_position
	heart.z_index = 100

	# Add to the main scene (not the CanvasLayer)
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		main.add_child(heart)
	else:
		return

	# Target position: health display area (top-left corner)
	var target_pos = Vector2(140, 45)

	# Phase 1: Pulse for 0.4 seconds
	var pulse_tween = heart.create_tween()
	pulse_tween.set_loops(4)  # Pulse 4 times over 0.4 sec
	pulse_tween.tween_property(heart, "scale", Vector2(32.0, 32.0), 0.05).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(heart, "scale", Vector2(30.0, 30.0), 0.05).set_ease(Tween.EASE_IN_OUT)

	# Phase 2: Fly to corner and shrink (in parallel)
	var fly_tween = heart.create_tween()
	fly_tween.set_parallel(true)
	fly_tween.tween_property(heart, "position", target_pos, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.4)
	fly_tween.tween_property(heart, "scale", Vector2(1.0, 1.0), 0.6).set_ease(Tween.EASE_IN_OUT).set_delay(0.4)
	fly_tween.tween_property(heart, "modulate:a", 0.0, 0.2).set_delay(0.9)
	fly_tween.chain().tween_callback(heart.queue_free)
