extends ShootingEnemy
class_name StarEnemy
## Star enemy - Level 7 special enemy.
## Has 6 HP, medium-fast zigzag movement, and fires star projectiles at a moderate rate.

## Custom projectile texture
var _star_projectile_texture: Texture2D = null


func _ready() -> void:
	# Load custom projectile texture before calling super (which loads projectile scene)
	_star_projectile_texture = load("res://assets/sprites/star-attack-1.png")

	super._ready()

	# Star has 6 HP (survives 5 hits)
	health = 6

	# Moderate fire rate (3.5 vs standard 4.0)
	fire_rate = 3.5

	# Medium-fast zigzag movement (100-140)
	zigzag_speed = randf_range(100.0, 140.0)


func _fire_projectile() -> void:
	if not _projectile_scene:
		return

	var projectile = _projectile_scene.instantiate()
	# Position projectile at enemy location
	projectile.global_position = global_position

	# Apply custom star texture
	if _star_projectile_texture and projectile.has_method("set_texture"):
		projectile.set_texture(_star_projectile_texture)

	# Scale star projectile to reasonable size
	if projectile.has_method("set_projectile_scale"):
		projectile.set_projectile_scale(0.5)

	# Add to scene tree (use parent to avoid projectile being destroyed with enemy)
	if get_parent():
		get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
