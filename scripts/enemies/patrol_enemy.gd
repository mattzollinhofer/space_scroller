extends BaseEnemy
class_name PatrolEnemy
## Patrol enemy that oscillates horizontally while scrolling left.
## Red/orange tinted variant of the base enemy.
## Requires 2 hits to destroy (more health than stationary enemy).

## Horizontal patrol range (total distance from left to right)
@export var patrol_range: float = 200.0

## Speed of patrol oscillation in pixels per second
@export var patrol_speed: float = 100.0

## Internal tracking for patrol movement
var _patrol_offset: float = 0.0
var _patrol_direction: float = 1.0
var _base_x: float = 0.0


func _ready() -> void:
	super._ready()
	# Patrol enemies require 2 hits to destroy
	health = 2
	# Store initial X position as base for patrol calculation
	_base_x = position.x


func _process(delta: float) -> void:
	if _is_destroying:
		return

	# Move base position left at scroll speed
	_base_x -= scroll_speed * delta

	# Update patrol oscillation
	_patrol_offset += _patrol_direction * patrol_speed * delta

	# Reverse direction when reaching patrol bounds
	var half_range = patrol_range / 2.0
	if _patrol_offset >= half_range:
		_patrol_offset = half_range
		_patrol_direction = -1.0
	elif _patrol_offset <= -half_range:
		_patrol_offset = -half_range
		_patrol_direction = 1.0

	# Set actual position to base + offset
	position.x = _base_x + _patrol_offset

	# Despawn when base position is well off-screen (left edge)
	if _base_x < -100 - patrol_range:
		_despawn()
