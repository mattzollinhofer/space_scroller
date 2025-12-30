extends Area2D
## Projectile fired by player. Travels right and damages enemies on contact.
## Despawns when leaving the right edge of the screen.

## Movement speed in pixels per second
@export var speed: float = 900.0

## Damage dealt to enemies on hit
@export var damage: int = 1

## Right edge of viewport plus margin for despawn
var _despawn_x: float = 2148.0


func _ready() -> void:
	# Get viewport width for despawn check
	_despawn_x = ProjectSettings.get_setting("display/window/size/viewport_width") + 100.0

	# Connect area_entered signal for enemy collision
	area_entered.connect(_on_area_entered)


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
		# Destroy projectile on hit
		queue_free()
