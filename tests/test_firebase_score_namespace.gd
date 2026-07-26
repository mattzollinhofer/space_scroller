extends Node2D
## Unit test: FirebaseService namespaces the scores path by game_id so multiple
## games can share one Realtime Database. An empty game_id falls back to the root
## "scores" node (legacy behavior); a set game_id produces "<game_id>/scores".

func _ready() -> void:
	print("=== Test: Firebase Score Path Namespacing ===")

	var service = Node.new()
	service.set_script(load("res://scripts/autoloads/firebase_service.gd"))

	# Legacy fallback: no game_id -> root scores node
	service._game_id = ""
	if service._scores_path() != "scores":
		_fail("Empty game_id should map to 'scores', got '%s'" % service._scores_path())
		service.free()
		return
	print("  - empty game_id -> 'scores': OK")

	# Namespaced: game_id -> "<game_id>/scores"
	service._game_id = "test_game"
	if service._scores_path() != "test_game/scores":
		_fail("game_id 'test_game' should map to 'test_game/scores', got '%s'" % service._scores_path())
		service.free()
		return
	print("  - game_id 'test_game' -> 'test_game/scores': OK")

	service.free()

	# Integration: the shipped config must yield a namespaced "<game_id>/scores"
	# path (not the root "scores"), proving _load_config() actually reads the
	# "game_id" key and wires it through. Repo-agnostic: passes for any game_id,
	# but fails if the config key is renamed/typo'd (path would fall back to "scores").
	var configured = Node.new()
	configured.set_script(load("res://scripts/autoloads/firebase_service.gd"))
	add_child(configured)  # _ready() -> _load_config() reads res://config/firebase_config.json
	var configured_path = configured._scores_path()
	if configured_path == "scores" or not configured_path.ends_with("/scores"):
		_fail("Shipped config should yield a namespaced '<game_id>/scores' path, got '%s'" % configured_path)
		configured.queue_free()
		return
	print("  - shipped config -> namespaced path '%s': OK" % configured_path)
	configured.queue_free()

	_pass()


func _pass() -> void:
	print("=== TEST PASSED ===")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
