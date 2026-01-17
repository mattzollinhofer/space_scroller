extends ShootingEnemy
class_name BunnyEnemy
## Bunny enemy - Level 6 special enemy.
## Has 5 HP, very slow zigzag movement (60-80), and fires balloon projectiles at a slow rate.

## Custom projectile texture
var _balloon_projectile_texture: Texture2D = null


func _ready() -> void:
	# Load custom projectile texture before calling super (which loads projectile scene)
	_balloon_projectile_texture = load("res://assets/sprites/balloon-attack-1.png")

	super._ready()

	# Bunny has 5 HP (survives 4 hits)
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

	# Apply custom balloon texture
	if _balloon_projectile_texture and projectile.has_method("set_texture"):
		projectile.set_texture(_balloon_projectile_texture)

	# Make balloon projectile 1.75x larger
	if projectile.has_method("set_projectile_scale"):
		projectile.set_projectile_scale(1.75)

	# Add to scene tree (use parent to avoid projectile being destroyed with enemy)
	if get_parent():
		get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
