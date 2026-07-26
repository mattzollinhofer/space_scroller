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

	# The boss theme/sprites/attack ids/tuning are content that gets rebalanced,
	# so this test verifies the config is STRUCTURALLY complete and valid rather
	# than pinning specific values that drift on every content change.

	# Test 2: Boss sprite is a present, valid, existing res:// image
	if not "boss_sprite" in level_data.metadata:
		_fail("Level 6 metadata missing boss_sprite")
		return

	var boss_sprite = level_data.metadata.boss_sprite
	if not _is_valid_sprite_path(boss_sprite):
		_fail("Boss sprite should be an existing res:// .png, got '%s'" % str(boss_sprite))
		return

	print("Boss sprite: %s (valid)" % boss_sprite)

	# Test 3: Boss health is a positive integer
	if not "health" in boss_config:
		_fail("Boss config missing health field")
		return

	var health = int(boss_config.health)
	if health <= 0:
		_fail("Boss health should be positive, got: %d" % health)
		return

	print("Boss health: %d HP (valid)" % health)

	# Test 4: Attacks is a non-empty array of non-negative attack ids
	if not "attacks" in boss_config:
		_fail("Boss config missing attacks array")
		return

	var attacks = boss_config.attacks
	if not attacks is Array or attacks.size() == 0:
		_fail("Boss attacks should be a non-empty array, got: %s" % str(attacks))
		return

	for i in range(attacks.size()):
		if int(attacks[i]) < 0:
			_fail("Boss attack %d should be a valid (non-negative) id, got: %d" % [i, int(attacks[i])])
			return

	print("Boss attacks: %s (valid)" % str(attacks))

	# Test 5: Projectile sprite is a present, valid, existing res:// image
	if not "projectile_sprite" in boss_config:
		_fail("Boss config missing projectile_sprite")
		return

	var projectile_sprite = boss_config.projectile_sprite
	if not _is_valid_sprite_path(projectile_sprite):
		_fail("Projectile sprite should be an existing res:// .png, got '%s'" % str(projectile_sprite))
		return

	print("Projectile sprite: %s (valid)" % projectile_sprite)

	# Test 6: Boss scale is a positive number
	if not "scale" in boss_config:
		_fail("Boss config missing scale field")
		return

	var scale_val = boss_config.scale
	if scale_val <= 0.0:
		_fail("Boss scale should be positive, got: %f" % scale_val)
		return

	print("Boss scale: %f (valid)" % scale_val)

	# Test 7: attack_cooldown is a positive number
	if not "attack_cooldown" in boss_config:
		_fail("Boss config missing attack_cooldown field")
		return

	var cooldown = boss_config.attack_cooldown
	if cooldown <= 0.0:
		_fail("Attack cooldown should be positive, got: %f" % cooldown)
		return

	print("Attack cooldown: %f seconds (valid)" % cooldown)

	# All checks passed
	_pass()


## A sprite field is valid if it's a non-empty res:// .png that actually exists.
func _is_valid_sprite_path(path) -> bool:
	if typeof(path) != TYPE_STRING or path.is_empty():
		return false
	if not path.begins_with("res://") or not path.ends_with(".png"):
		return false
	return ResourceLoader.exists(path)


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level 6 boss configuration is structurally complete and valid.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
