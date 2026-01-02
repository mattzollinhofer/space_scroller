extends Node2D
## Integration test: Level 6 boss configuration is complete and correct
## Verifies boss sprite, attacks array, health, and projectile sprite in level_6.json

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""


func _ready() -> void:
	print("=== Test: Level 6 Boss Configuration ===")

	# Load level_6.json
	var level6_path = "res://levels/level_6.json"
	if not FileAccess.file_exists(level6_path):
		_fail("Level 6 JSON file does not exist at: %s" % level6_path)
		return

	var file = FileAccess.open(level6_path, FileAccess.READ)
	if not file:
		_fail("Could not open Level 6 JSON file")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		_fail("Failed to parse Level 6 JSON: %s" % json.get_error_message())
		return

	var level_data = json.data
	print("Level 6 JSON parsed successfully")

	# Test 1: Verify metadata and boss_config exist
	if not "metadata" in level_data:
		_fail("Level 6 JSON missing metadata section")
		return

	if not "boss_config" in level_data.metadata:
		_fail("Level 6 metadata missing boss_config")
		return

	var boss_config = level_data.metadata.boss_config
	print("Boss config found: %s" % str(boss_config))

	# Test 2: Verify boss sprite is jelly-monster-1.png
	if not "boss_sprite" in level_data.metadata:
		_fail("Level 6 metadata missing boss_sprite")
		return

	var boss_sprite = level_data.metadata.boss_sprite
	var expected_boss_sprite = "res://assets/sprites/jelly-monster-1.png"
	if boss_sprite != expected_boss_sprite:
		_fail("Boss sprite should be '%s', got '%s'" % [expected_boss_sprite, boss_sprite])
		return

	print("Boss sprite: %s (correct)" % boss_sprite)

	# Test 3: Verify boss health is 24-25 HP
	if not "health" in boss_config:
		_fail("Boss config missing health field")
		return

	var health = int(boss_config.health)
	if health < 24 or health > 25:
		_fail("Boss health should be 24-25, got: %d" % health)
		return

	print("Boss health: %d HP (correct)" % health)

	# Test 4: Verify attacks array is [11, 12, 13]
	if not "attacks" in boss_config:
		_fail("Boss config missing attacks array")
		return

	var attacks = boss_config.attacks
	if attacks.size() != 3:
		_fail("Boss attacks should have exactly 3 attacks, got: %d" % attacks.size())
		return

	var expected_attacks = [11, 12, 13]
	for i in range(3):
		if int(attacks[i]) != expected_attacks[i]:
			_fail("Boss attack %d should be %d, got: %d" % [i, expected_attacks[i], int(attacks[i])])
			return

	print("Boss attacks: %s (correct)" % str(attacks))

	# Test 5: Verify projectile sprite is weapon-jelly-1.png
	if not "projectile_sprite" in boss_config:
		_fail("Boss config missing projectile_sprite")
		return

	var projectile_sprite = boss_config.projectile_sprite
	var expected_projectile_sprite = "res://assets/sprites/weapon-jelly-1.png"
	if projectile_sprite != expected_projectile_sprite:
		_fail("Projectile sprite should be '%s', got '%s'" % [expected_projectile_sprite, projectile_sprite])
		return

	print("Projectile sprite: %s (correct)" % projectile_sprite)

	# Test 6: Verify boss scale is 1.5
	if not "scale" in boss_config:
		_fail("Boss config missing scale field")
		return

	var scale_val = boss_config.scale
	if abs(scale_val - 1.5) > 0.01:
		_fail("Boss scale should be 1.5, got: %f" % scale_val)
		return

	print("Boss scale: %f (correct)" % scale_val)

	# Test 7: Verify attack_cooldown is 1.0
	if not "attack_cooldown" in boss_config:
		_fail("Boss config missing attack_cooldown field")
		return

	var cooldown = boss_config.attack_cooldown
	if abs(cooldown - 1.0) > 0.01:
		_fail("Attack cooldown should be 1.0, got: %f" % cooldown)
		return

	print("Attack cooldown: %f seconds (correct)" % cooldown)

	# Test 8: Verify boss sprite asset exists
	if not ResourceLoader.exists(expected_boss_sprite):
		_fail("Boss sprite asset does not exist: %s" % expected_boss_sprite)
		return

	print("Boss sprite asset exists")

	# Test 9: Verify projectile sprite asset exists
	if not ResourceLoader.exists(expected_projectile_sprite):
		_fail("Projectile sprite asset does not exist: %s" % expected_projectile_sprite)
		return

	print("Projectile sprite asset exists")

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level 6 boss configuration is complete and correct.")
	print("- Sprite: jelly-monster-1.png")
	print("- Health: 24 HP")
	print("- Attacks: [11, 12, 13] (Up/Down Shooting, Grow/Shrink, Rapid Jelly)")
	print("- Projectile: weapon-jelly-1.png")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
