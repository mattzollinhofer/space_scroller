extends ShootingEnemy
class_name JellySnailEnemy
## Jelly Snail enemy - Level 6 special enemy.
## Has 5 HP, very slow zigzag movement (60-80), and fires jelly projectiles at a slow rate.

## Custom projectile texture
var _jelly_projectile_texture: Texture2D = null


func _ready() -> void:
	# Load custom projectile texture before calling super (which loads projectile scene)
	_jelly_projectile_texture = load("res://assets/sprites/weapon-jelly-1.png")

	super._ready()

	# Jelly Snail has 5 HP (survives 4 hits)
	health = 5

	# Slow fire rate (6.0 vs standard 4.0)
	fire_rate = 6.0

	# Slow zigzag movement (60-80 vs standard ~120)
	zigzag_speed = randf_range(60.0, 80.0)


func _fire_projectile() -> void:
	if not _projectile_scene:
		return

	var projectile = _projectile_scene.instantiate()
	# Position projectile at enemy location
	projectile.global_position = global_position

	# Apply custom jelly texture
	if _jelly_projectile_texture and projectile.has_method("set_texture"):
		projectile.set_texture(_jelly_projectile_texture)

	# Make jelly projectile larger than default (adjusted for 256px sprites, matching garlic)
	if projectile.has_method("set_projectile_scale"):
		projectile.set_projectile_scale(0.9375)

	# Add to scene tree (use parent to avoid projectile being destroyed with enemy)
	if get_parent():
		get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
