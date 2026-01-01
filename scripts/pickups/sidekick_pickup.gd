extends Area2D
class_name SidekickPickup
## Sidekick pickup that spawns a UFO sidekick companion when collected.
## Spawns from a random edge and zigzags across the screen.

## Movement speed
@export var move_speed: float = 200.0

## Zigzag vertical speed
@export var zigzag_speed: float = 150.0

## Edge where pickup spawned (determines travel direction)
enum SpawnEdge { LEFT, RIGHT, TOP, BOTTOM }
var _spawn_edge: SpawnEdge = SpawnEdge.RIGHT

## Movement direction vector
var _move_direction: Vector2 = Vector2.LEFT

## Zigzag direction (1 or -1)
var _zigzag_direction: float = 1.0

## Y bounds (match enemy bounds)
const Y_MIN: float = 140.0
const Y_MAX: float = 1396.0

## Viewport dimensions for despawn check
var _viewport_width: float = 2048.0
var _viewport_height: float = 1536.0

## Sidekick scene to spawn when collected
var sidekick_scene: PackedScene = preload("res://scenes/pickups/sidekick.tscn")

## Possible sidekick sprite paths (randomized on spawn)
const SIDEKICK_SPRITES := [
	"res://assets/sprites/star-dragon-1.png",
	"res://assets/sprites/cosmic-cat-2.png",
	"res://assets/sprites/player.png",
	"res://assets/sprites/friend-ufo-1.png"
]

## The randomly chosen sprite path for this pickup
var _sprite_path: String = ""

## Signal when collected
signal collected()


func _ready() -> void:
	randomize()  # Ensure RNG is seeded
	body_entered.connect(_on_body_entered)
	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	_viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	_zigzag_direction = 1.0 if randf() > 0.5 else -1.0
	# Randomize the sprite for both pickup and future sidekick
	_randomize_sprite()


## Configure the pickup based on which edge it spawns from
func setup(spawn_edge: SpawnEdge) -> void:
	_spawn_edge = spawn_edge
	match spawn_edge:
		SpawnEdge.LEFT:
			_move_direction = Vector2.RIGHT
		SpawnEdge.RIGHT:
			_move_direction = Vector2.LEFT
		SpawnEdge.TOP:
			_move_direction = Vector2.DOWN
		SpawnEdge.BOTTOM:
			_move_direction = Vector2.UP


func _process(delta: float) -> void:
	# Primary movement toward opposite edge
	position += _move_direction * move_speed * delta

	# Zigzag movement (perpendicular to primary direction)
	if _spawn_edge in [SpawnEdge.LEFT, SpawnEdge.RIGHT]:
		# Horizontal travel: zigzag vertically
		position.y += _zigzag_direction * zigzag_speed * delta
		if position.y >= Y_MAX:
			position.y = Y_MAX
			_zigzag_direction = -1.0
		elif position.y <= Y_MIN:
			position.y = Y_MIN
			_zigzag_direction = 1.0
	else:
		# Vertical travel: zigzag horizontally
		position.x += _zigzag_direction * zigzag_speed * delta
		if position.x >= _viewport_width - 100:
			_zigzag_direction = -1.0
		elif position.x <= 100:
			_zigzag_direction = 1.0

	# Despawn when off screen (opposite edge)
	if _is_off_screen():
		queue_free()


func _is_off_screen() -> bool:
	match _spawn_edge:
		SpawnEdge.LEFT:
			return position.x > _viewport_width + 100
		SpawnEdge.RIGHT:
			return position.x < -100
		SpawnEdge.TOP:
			return position.y > _viewport_height + 100
		SpawnEdge.BOTTOM:
			return position.y < -100
	return false


func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player (has player methods)
	if body.has_method("get_lives"):
		# Defer sidekick spawn to avoid physics query issues
		call_deferred("_spawn_sidekick", body)
		collected.emit()
		_play_sfx("pickup_collect")
		_play_collect_animation()


func _spawn_sidekick(player: Node2D) -> void:
	if not sidekick_scene:
		push_warning("No sidekick scene assigned to SidekickPickup")
		return

	if not is_instance_valid(player):
		return

	# Check if a sidekick already exists using the "sidekick" group
	var existing_sidekicks = get_tree().get_nodes_in_group("sidekick")
	if existing_sidekicks.size() > 0:
		# Sidekick already exists, don't spawn another
		return

	# Spawn the sidekick
	var sidekick = sidekick_scene.instantiate()
	sidekick.name = "Sidekick"
	sidekick.position = player.position + Vector2(-50, -30)  # Start at offset position

	# Pass player reference and sprite path to sidekick
	if sidekick.has_method("setup"):
		sidekick.setup(player, _sprite_path)

	# Add to the same parent as this pickup (Main scene or test scene)
	get_parent().add_child(sidekick)


func _play_collect_animation() -> void:
	# Disable collision
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Stop movement
	set_process(false)

	# Scale up and fade out
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", sprite.scale * 1.5, 0.3)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(queue_free)
	else:
		queue_free()


## Randomly select and apply one of the sidekick sprites
func _randomize_sprite() -> void:
	_sprite_path = SIDEKICK_SPRITES[randi() % SIDEKICK_SPRITES.size()]
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(_sprite_path)
		if texture:
			sprite.texture = texture


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
