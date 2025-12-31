extends BaseEnemy
class_name ShootingEnemy
## Ranged enemy that fires projectiles toward the left every 4 seconds.
## Has 1 HP (fragile ranged attacker).

## Time between shots in seconds
@export var fire_rate: float = 4.0

## Projectile scene to instantiate
var _projectile_scene: PackedScene = null

## Timer for firing
var _fire_timer: float = 0.0


func _ready() -> void:
	super._ready()
	# Shooting enemies have 1 HP
	health = 1

	# Load projectile scene
	_projectile_scene = load("res://scenes/enemies/enemy_projectile.tscn")

	# Start with some initial delay so it doesn't fire immediately
	_fire_timer = fire_rate * 0.5


func _process(delta: float) -> void:
	super._process(delta)

	if _is_destroying:
		return

	# Update fire timer
	_fire_timer += delta

	# Fire projectile when timer reaches fire_rate
	if _fire_timer >= fire_rate:
		_fire_timer = 0.0
		_fire_projectile()


func _fire_projectile() -> void:
	if not _projectile_scene:
		return

	var projectile = _projectile_scene.instantiate()
	# Position projectile at enemy location
	projectile.global_position = global_position

	# Add to scene tree (use parent to avoid projectile being destroyed with enemy)
	if get_parent():
		get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
