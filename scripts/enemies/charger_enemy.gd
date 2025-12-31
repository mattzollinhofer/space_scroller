extends BaseEnemy
class_name ChargerEnemy
## Fast enemy that locks onto player Y position and charges horizontally left.
## Has 1 HP (high-risk/high-reward to destroy).
## Moves at 2-3x normal scroll speed (360-540 px/s).

## Charge speed (2.5x normal scroll speed of 180)
@export var charge_speed: float = 450.0


func _ready() -> void:
	super._ready()
	# Charger enemies have 1 HP
	health = 1


func _process(delta: float) -> void:
	if _is_destroying:
		return

	# Override base movement - charge left at high speed
	# No zigzag - straight horizontal charge
	position.x -= charge_speed * delta

	# Despawn when off-screen (left edge)
	if position.x < -100:
		_despawn()
