extends Area2D
class_name Sidekick
## UFO sidekick companion that follows the player with a position offset.
## Provides extra firepower by shooting when the player shoots.

## Position offset from player (behind and above)
@export var follow_offset: Vector2 = Vector2(-50, -30)

## Smooth follow lerp weight (higher = faster following)
@export var follow_speed: float = 5.0

## Reference to the player being followed
var _player: Node2D = null

## Target position to follow (player position + offset)
var _target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("sidekick")


## Setup the sidekick with player reference
func setup(player: Node2D) -> void:
	_player = player
	if _player:
		_target_position = _player.position + follow_offset
		position = _target_position


func _process(delta: float) -> void:
	if not _player or not is_instance_valid(_player):
		# Player is gone, clean up sidekick
		queue_free()
		return

	# Update target position based on player
	_target_position = _player.position + follow_offset

	# Smoothly lerp toward target position
	position = position.lerp(_target_position, follow_speed * delta)
