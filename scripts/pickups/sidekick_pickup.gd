extends BasePickup
class_name SidekickPickup
## Sidekick pickup that spawns a UFO sidekick companion when collected.
## Spawns from a random edge and zigzags across the screen.

## Sidekick scene to spawn when collected
var sidekick_scene: PackedScene = preload("res://scenes/pickups/sidekick.tscn")

## Possible sidekick sprite paths (randomized on spawn)
const SIDEKICK_SPRITES := [
	"res://assets/sprites/star-dragon-1.png",
	"res://assets/sprites/cosmic-cat-2.png",
	"res://assets/sprites/player.png",
	"res://assets/sprites/friend-ufo-1.png",
	"res://assets/sprites/rocky-1.png",
	"res://assets/sprites/space-sheep-1.png",
	"res://assets/sprites/comsic-hampster-1.png",
	"res://assets/sprites/astro-maple-2.png",
	"res://assets/sprites/garfield-1.png",
	"res://assets/sprites/declyn-dragon-1.png"
]

## The randomly chosen sprite path for this pickup
var _sprite_path: String = ""


## Called after base _ready() completes
func _pickup_ready() -> void:
	randomize()  # Ensure RNG is seeded
	_randomize_sprite()


## Override collection behavior - spawn sidekick companion
func _on_collected(body: Node2D) -> void:
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
	for existing in existing_sidekicks:
		# Remove the old sidekick to make room for the new one
		existing.queue_free()

	# Spawn the sidekick
	var sidekick = sidekick_scene.instantiate()
	sidekick.name = "Sidekick"
	sidekick.position = player.position + Vector2(-50, -30)  # Start at offset position

	# Pass player reference and sprite path to sidekick
	if sidekick.has_method("setup"):
		sidekick.setup(player, _sprite_path)

	# Add to the same parent as this pickup (Main scene or test scene)
	get_parent().add_child(sidekick)


## Randomly select and apply one of the sidekick sprites
func _randomize_sprite() -> void:
	_sprite_path = SIDEKICK_SPRITES[randi() % SIDEKICK_SPRITES.size()]
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var texture = load(_sprite_path)
		if texture:
			sprite.texture = texture
