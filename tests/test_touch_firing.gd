extends Node2D
## Integration test: Touch input triggers continuous firing
## Tests that the fire button control works for both touch and mouse input.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _projectile_count: int = 0
var _expected_projectiles: int = 3  # Expect at least 3 projectiles from held fire
var _test_timeout: float = 5.0
var _timer: float = 0.0
var _hold_duration: float = 0.5  # Hold fire button for 0.5 seconds
var _hold_timer: float = 0.0
var _is_holding: bool = false

@onready var player: Node = null
@onready var fire_button: Node = null


func _ready() -> void:
	print("=== Test: Touch Firing - Continuous Fire ===")

	# Load projectile scene
	var projectile_scene = load("res://scenes/projectile.tscn")
	if not projectile_scene:
		_fail("Could not load projectile scene")
		return

	# Create player
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return
	player = player_scene.instantiate()
	player.position = Vector2(400, 768)
	player.projectile_scene = projectile_scene
	add_child(player)

	# Connect to projectile_fired signal to count shots
	if player.has_signal("projectile_fired"):
		player.projectile_fired.connect(_on_projectile_fired)
	else:
		_fail("Player does not have 'projectile_fired' signal")
		return

	# Create fire button
	var fire_button_scene = load("res://scenes/ui/fire_button.tscn")
	if not fire_button_scene:
		_fail("Could not load fire button scene - need to create scenes/ui/fire_button.tscn")
		return

	# Create a CanvasLayer for UI (mimics main.tscn UILayer structure)
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	fire_button = fire_button_scene.instantiate()
	ui_layer.add_child(fire_button)

	# Check if fire button has is_pressed method
	if not fire_button.has_method("is_pressed"):
		_fail("FireButton does not have 'is_pressed' method")
		return

	# Connect fire button to player (player needs to check fire button state)
	if player.has_method("set_fire_button"):
		player.set_fire_button(fire_button)
	else:
		# Manually set fire button reference if method doesn't exist
		if "fire_button" in player:
			player.fire_button = fire_button
		else:
			_fail("Player has no way to reference fire button - need set_fire_button method or fire_button property")
			return

	print("Test setup complete. Simulating fire button press...")

	# Simulate pressing the fire button (like a touch event)
	if fire_button.has_method("_simulate_press"):
		fire_button._simulate_press(true)
		_is_holding = true
	else:
		_fail("FireButton does not have '_simulate_press' method for testing")
		return


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Track hold duration
	if _is_holding:
		_hold_timer += delta

		# Release after hold duration
		if _hold_timer >= _hold_duration:
			if fire_button and fire_button.has_method("_simulate_press"):
				fire_button._simulate_press(false)
				_is_holding = false
				print("Fire button released after %.2f seconds" % _hold_timer)
				print("Projectiles fired: %d" % _projectile_count)

				# Check if we got enough projectiles
				if _projectile_count >= _expected_projectiles:
					_pass()
				else:
					_fail("Expected at least %d projectiles, got %d" % [_expected_projectiles, _projectile_count])
				return

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out - expected %d projectiles, got %d" % [_expected_projectiles, _projectile_count])


func _on_projectile_fired() -> void:
	_projectile_count += 1
	print("Projectile %d fired!" % _projectile_count)


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Touch fire button triggered continuous firing (%d projectiles in %.2fs)" % [_projectile_count, _hold_duration])
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
