extends Area2D
class_name Sidekick
## UFO sidekick companion that follows the player with a position offset.
## Provides extra firepower by shooting when the player shoots.

## Position offset from player (behind and above)
@export var follow_offset: Vector2 = Vector2(-50, -30)

## Smooth follow lerp weight (higher = faster following)
@export var follow_speed: float = 5.0

## Projectile scene to spawn when shooting
var projectile_scene: PackedScene = null

## Reference to the player being followed
var _player: Node2D = null

## Target position to follow (player position + offset)
var _target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("sidekick")
	# Load projectile scene
	projectile_scene = load("res://scenes/projectile.tscn")


## Setup the sidekick with player reference
func setup(player: Node2D) -> void:
	_player = player
	if _player:
		_target_position = _player.position + follow_offset
		position = _target_position
		# Connect to player's projectile_fired signal for synchronized shooting
		if _player.has_signal("projectile_fired"):
			_player.projectile_fired.connect(_on_player_projectile_fired)


func _process(delta: float) -> void:
	if not _player or not is_instance_valid(_player):
		# Player is gone, clean up sidekick
		queue_free()
		return

	# Update target position based on player
	_target_position = _player.position + follow_offset

	# Smoothly lerp toward target position
	position = position.lerp(_target_position, follow_speed * delta)


## Called when player fires a projectile - sidekick fires synchronized
func _on_player_projectile_fired() -> void:
	shoot()


## Spawn a projectile from the sidekick's position
func shoot() -> void:
	if not projectile_scene:
		push_warning("No projectile scene loaded for Sidekick")
		return

	# Spawn projectile at sidekick's position (offset slightly to the right)
	var projectile = projectile_scene.instantiate()
	# Position ahead of sidekick, with slight Y offset from player projectile
	projectile.position = position + Vector2(80, 0)

	# Add to Main scene so it persists independently
	get_parent().add_child(projectile)
