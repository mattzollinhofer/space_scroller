extends Area2D
## Projectile fired by player. Travels right and damages enemies on contact.
## Despawns when leaving the right edge of the screen.

## Movement speed in pixels per second
@export var speed: float = 900.0

## Damage dealt to enemies on hit
@export var damage: int = 1

## Right edge of viewport plus margin for despawn
var _despawn_x: float = 2148.0

## Impact spark scene for enemy hit effect
var _impact_spark_scene: PackedScene = null


func _ready() -> void:
	# Get viewport width for despawn check
	_despawn_x = ProjectSettings.get_setting("display/window/size/viewport_width") + 100.0

	# Connect area_entered signal for enemy collision
	area_entered.connect(_on_area_entered)

	# Preload impact spark scene
	_impact_spark_scene = load("res://scenes/impact_spark.tscn")


func _process(delta: float) -> void:
	# Move right
	position.x += speed * delta

	# Despawn when off right edge
	if position.x > _despawn_x:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Check if it's an enemy with take_hit method
	if area.has_method("take_hit"):
		area.take_hit(damage)
		# Spawn impact spark at collision point before destroying projectile
		_spawn_impact_spark()
		# Destroy projectile on hit
		queue_free()


## Spawns impact spark particle effect at current position
func _spawn_impact_spark() -> void:
	if _impact_spark_scene == null:
		return

	var spark = _impact_spark_scene.instantiate()
	spark.global_position = global_position

	# Add to parent so it persists after projectile is freed
	var parent = get_parent()
	if parent:
		parent.add_child(spark)

		# Auto-free after particles complete using tween callback
		var tween = spark.create_tween()
		# Wait for particle lifetime plus a small buffer
		tween.tween_interval(0.3)
		tween.tween_callback(spark.queue_free)
