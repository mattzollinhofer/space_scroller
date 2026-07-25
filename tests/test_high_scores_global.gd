extends Node2D
## Integration test: High Scores screen upgrades to the global leaderboard.
## Verifies local scores show on load, a non-empty global fetch replaces them,
## and an empty global fetch (offline/unconfigured) leaves the local scores.

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"


func _ready() -> void:
	print("=== Test: High Scores Global Leaderboard ===")

	_setup_local_scores()

	var screen = _instantiate_screen()
	if screen == null:
		return

	add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame

	# Local scores are shown on load
	var top = _top_score_label(screen)
	if top == null or not ("AAA" in top.text):
		_fail("Expected local score 'AAA' on load, got: %s" % _label_text(top))
		return

	# An empty global result keeps the local scores in place
	screen._on_global_scores_fetched([])
	await get_tree().process_frame
	await get_tree().process_frame
	top = _top_score_label(screen)
	if top == null or not ("AAA" in top.text):
		_fail("Empty global result should keep local scores, got: %s" % _label_text(top))
		return

	# A non-empty global result replaces the displayed scores
	var global_scores = [
		{"score": 99999, "initials": "ZZZ"},
		{"score": 88888, "initials": "YYY"},
	]
	screen._on_global_scores_fetched(global_scores)
	await get_tree().process_frame
	await get_tree().process_frame

	top = _top_score_label(screen)
	if top == null:
		_fail("No score labels after global fetch")
		return
	if not ("ZZZ" in top.text and "99,999" in top.text):
		_fail("Expected global top 'ZZZ - 99,999', got: %s" % top.text)
		return
	if "AAA" in top.text:
		_fail("Local score should be replaced by global, still shows: %s" % top.text)
		return

	_cleanup()
	_pass()


func _setup_local_scores() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)

	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")
	score_manager.load_high_scores()

	var local_scores = [
		{"score": 50000, "initials": "AAA"},
		{"score": 40000, "initials": "BBB"},
		{"score": 30000, "initials": "CCC"},
	]
	for entry in local_scores:
		score_manager.reset_score()
		score_manager.add_points(entry["score"])
		score_manager.save_high_score(entry["initials"])


func _instantiate_screen() -> Node:
	if not ResourceLoader.exists("res://scenes/ui/high_scores_screen.tscn"):
		_fail("high_scores_screen.tscn not found")
		return null
	var scene = load("res://scenes/ui/high_scores_screen.tscn")
	if scene == null:
		_fail("Failed to load high_scores_screen.tscn")
		return null
	return scene.instantiate()


## Return the rank-1 score entry label, or null if none present
func _top_score_label(root: Node) -> Label:
	var labels: Array = []
	_collect_score_labels(root, labels)
	for label in labels:
		if label.text.begins_with("1."):
			return label
	return null


func _collect_score_labels(node: Node, labels: Array) -> void:
	if node is Label:
		var text = node.text
		if text.length() > 0 and text[0].is_valid_int() and "." in text and " - " in text:
			labels.append(node)
	for child in node.get_children():
		_collect_score_labels(child, labels)


func _label_text(label: Label) -> String:
	if label == null:
		return "<none>"
	return label.text


func _cleanup() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").load_high_scores()


func _pass() -> void:
	print("=== TEST PASSED ===")
	await get_tree().create_timer(0.3).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit(1)
