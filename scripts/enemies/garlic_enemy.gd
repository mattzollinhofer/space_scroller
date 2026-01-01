extends ShootingEnemy
class_name GarlicEnemy
## Garlic Man enemy - Level 4 special enemy.
## Has 3 HP, faster zigzag movement (240-280), and fires pizza projectiles at a faster rate.

## Custom projectile texture
var _pizza_projectile_texture: Texture2D = null


func _ready() -> void:
	# Load custom projectile texture before calling super (which loads projectile scene)
	_pizza_projectile_texture = load("res://assets/sprites/pizza-attack-1.png")

	super._ready()

	# Garlic Man has 3 HP (survives 2 hits)
	health = 3

	# Faster fire rate (1.0 vs standard 4.0)
	fire_rate = 1.0

	# Faster zigzag movement (240-280 vs standard ~120)
	zigzag_speed = randf_range(240.0, 280.0)


func _fire_projectile() -> void:
	if not _projectile_scene:
		return

	var projectile = _projectile_scene.instantiate()
	# Position projectile at enemy location
	projectile.global_position = global_position

	# Apply custom pizza texture
	if _pizza_projectile_texture and projectile.has_method("set_texture"):
		projectile.set_texture(_pizza_projectile_texture)

	# Make pizza projectile 50% larger than default (adjusted for 256px sprites)
	if projectile.has_method("set_projectile_scale"):
		projectile.set_projectile_scale(0.9375)

	# Add to scene tree (use parent to avoid projectile being destroyed with enemy)
	if get_parent():
		get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
