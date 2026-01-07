extends ShootingEnemy
class_name CrabEnemy
## Crab enemy - Level 3 special enemy.
## Has 3 HP, medium-fast zigzag movement, and fires claw projectiles.

## Custom projectile texture
var _claw_projectile_texture: Texture2D = null


func _ready() -> void:
	# Load custom projectile texture before calling super (which loads projectile scene)
	_claw_projectile_texture = load("res://assets/sprites/crab-claw-attack-1.png")

	super._ready()

	# Crab has 3 HP (survives 2 hits)
	health = 3

	# Medium fire rate (1.5 seconds)
	fire_rate = 1.5

	# Medium-fast zigzag movement (200-240)
	zigzag_speed = randf_range(200.0, 240.0)


func _fire_projectile() -> void:
	if not _projectile_scene:
		return

	var projectile = _projectile_scene.instantiate()
	# Position projectile at enemy location
	projectile.global_position = global_position

	# Apply custom claw texture
	if _claw_projectile_texture and projectile.has_method("set_texture"):
		projectile.set_texture(_claw_projectile_texture)

	# Make claw projectile slightly larger
	if projectile.has_method("set_projectile_scale"):
		projectile.set_projectile_scale(0.75)

	# Add to scene tree (use parent to avoid projectile being destroyed with enemy)
	if get_parent():
		get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
