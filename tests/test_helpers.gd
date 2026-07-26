extends RefCounted
## Shared helpers for the standalone scene-based test suite.
##
## The suite's dominant flakiness source is fixed `create_timer(N).timeout`
## sleeps used as synchronization points: the test guesses how long an async
## event (a spawn, a collection, a state transition, a tween) will take, then
## checks once. Under CPU load the guess is wrong and the test flakes.
##
## `poll_until` replaces that pattern: it re-checks a condition every frame and
## returns the instant the condition holds, bounded by a timeout. Tests become
## both faster (no worst-case sleep) and robust (no race).
##
## Loaded via preload so it works under the bare `godot --headless <scene>` runner
## (no editor scan / global class cache required):
##   const TestHelpers = preload("res://tests/test_helpers.gd")
##   if not await TestHelpers.poll_until(get_tree(), func(): return _hit): _fail(...)


## Poll `predicate` every `interval` seconds until it returns true, or until
## `timeout` seconds elapse. Returns true if the condition was met, false on
## timeout. Callers await the result and branch on it for a clear diagnostic.
static func poll_until(tree: SceneTree, predicate: Callable, timeout: float = 5.0, interval: float = 0.05) -> bool:
	var deadline := tree.create_timer(timeout)
	while deadline.time_left > 0.0:
		if predicate.call():
			return true
		await tree.create_timer(interval).timeout
	return predicate.call()


## Await `frames` process frames. Use for state that is known to propagate over a
## small fixed number of frames (not for waiting on async events - use poll_until).
static func wait_frames(tree: SceneTree, frames: int) -> void:
	for _i in range(frames):
		await tree.process_frame
