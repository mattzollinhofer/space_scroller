extends Area2D
class_name Sidekick
## UFO sidekick companion that follows the player with a position offset.
## Provides extra firepower by shooting when the player shoots.
## Destroyed on contact with enemies or when player dies.

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

## Whether the sidekick is currently being destroyed (prevents double-processing)
var _is_destroying: bool = false

## Current sprite path (for persistence between levels)
var _current_sprite_path: String = ""


func _ready() -> void:
	add_to_group("sidekick")
	# Load projectile scene
	projectile_scene = load("res://scenes/projectile.tscn")
	# Connect signal for collision detection with enemies (Area2D)
	area_entered.connect(_on_area_entered)


## Setup the sidekick with player reference and sprite
func setup(player: Node2D, sprite_path: String = "") -> void:
	_player = player
	if _player:
		_target_position = _player.position + follow_offset
		position = _target_position
		# Connect to player's projectile_fired signal for synchronized shooting
		if _player.has_signal("projectile_fired"):
			_player.projectile_fired.connect(_on_player_projectile_fired)
		# Connect to player's died signal for cleanup
		if _player.has_signal("died"):
			_player.died.connect(_on_player_died)
	# Apply the sprite from the pickup (or randomize if not provided)
	if sprite_path != "":
		_set_sprite(sprite_path)
	else:
		_randomize_sprite()


func _process(delta: float) -> void:
	if _is_destroying:
		return

	if not _player or not is_instance_valid(_player):
		# Player is gone, clean up sidekick
		_destroy()
		return

	# Update target position based on player
	_target_position = _player.position + follow_offset

	# Smoothly lerp toward target position
	position = position.lerp(_target_position, follow_speed * delta)


## Called when another Area2D enters our collision area
func _on_area_entered(area: Area2D) -> void:
	if _is_destroying:
		return

	# Check if it's an enemy (enemies are on layer 2)
	# Enemies extend BaseEnemy which has health property
	if area.has_method("take_hit") or area.get("health") != null:
		print("Sidekick hit by enemy!")
		_destroy()


## Called when player fires a projectile - sidekick fires synchronized
func _on_player_projectile_fired() -> void:
	if _is_destroying:
		return
	shoot()


## Called when player dies - sidekick should be destroyed
func _on_player_died() -> void:
	if _is_destroying:
		return
	print("Player died - destroying sidekick")
	_destroy()


## Map buddy sprites to their projectile sprites
const BUDDY_PROJECTILES := {
	"res://assets/sprites/friend-ufo-1.png": "res://assets/sprites/sidekick-attack-1.png",
	"res://assets/sprites/star-dragon-1.png": "res://assets/sprites/weapon-dragon-1.png",
	"res://assets/sprites/cosmic-cat-2.png": "res://assets/sprites/weapon-celestial-cat-1.png",
	"res://assets/sprites/player.png": "res://assets/sprites/laser-bolt.png"
}

## Spawn a projectile from the sidekick's position
func shoot() -> void:
	if _is_destroying:
		return

	if not projectile_scene:
		push_warning("No projectile scene loaded for Sidekick")
		return

	# Spawn projectile at sidekick's position (offset slightly to the right)
	var projectile = projectile_scene.instantiate()
	# Position ahead of sidekick, with slight Y offset from player projectile
	projectile.position = position + Vector2(80, 0)

	# Add to Main scene so it persists independently
	get_parent().add_child(projectile)

	# Apply buddy-specific projectile sprite
	var projectile_sprite = BUDDY_PROJECTILES.get(_current_sprite_path, "")
	if projectile_sprite != "":
		var sprite_node = projectile.get_node_or_null("Sprite2D")
		if sprite_node and ResourceLoader.exists(projectile_sprite):
			sprite_node.texture = load(projectile_sprite)

	# Play sidekick shoot sound (different from player)
	_play_sfx("sidekick_shoot")


## Destroy the sidekick with visual animation
func _destroy() -> void:
	if _is_destroying:
		return
	_is_destroying = true

	# Disconnect from player signals to avoid errors
	if _player and is_instance_valid(_player):
		if _player.has_signal("projectile_fired"):
			if _player.projectile_fired.is_connected(_on_player_projectile_fired):
				_player.projectile_fired.disconnect(_on_player_projectile_fired)
		if _player.has_signal("died"):
			if _player.died.is_connected(_on_player_died):
				_player.died.disconnect(_on_player_died)

	# Disable collision during animation
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Play destruction animation (scale up and fade out like pickup)
	_play_destruction_animation()


## Play destruction animation: scale up and fade out
func _play_destruction_animation() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		queue_free()
		return

	# Get current values
	var original_scale = sprite.scale

	# Animate: scale up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", original_scale * 2.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)

	# Queue free after animation completes
	tween.chain().tween_callback(queue_free)


## Apply a specific sprite texture
func _set_sprite(sprite_path: String) -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	var texture = load(sprite_path)
	if texture:
		sprite.texture = texture
		_current_sprite_path = sprite_path


## Get the current sprite path (for persistence between levels)
func get_sprite_path() -> String:
	return _current_sprite_path


## Randomly select and apply one of the sidekick sprites (uses SidekickPickup's constant)
func _randomize_sprite() -> void:
	var sprites = SidekickPickup.SIDEKICK_SPRITES
	var random_path = sprites[randi() % sprites.size()]
	_set_sprite(random_path)


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
