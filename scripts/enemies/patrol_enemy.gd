extends BaseEnemy
class_name PatrolEnemy
## Tougher enemy variant that requires 2 hits to destroy.
## Uses different sprite to distinguish from 1-HP enemies.

func _ready() -> void:
	super._ready()
	# Patrol enemies require 2 hits to destroy
	health = 2
