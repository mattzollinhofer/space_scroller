extends Node
## ScoreManager autoload singleton for tracking player score.
## Connects to enemy died signals to award points.
## Emits score_changed signal for UI updates.

## Emitted when score changes
signal score_changed(new_score: int)

## Current score for the active game session
var _current_score: int = 0

## Point values for different enemy types
const POINTS_STATIONARY_ENEMY: int = 100
const POINTS_PATROL_ENEMY: int = 200


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Get the current score
func get_score() -> int:
	return _current_score


## Add points to the score
func add_points(amount: int) -> void:
	_current_score += amount
	score_changed.emit(_current_score)


## Reset score to zero (called on new game start)
func reset_score() -> void:
	_current_score = 0
	score_changed.emit(_current_score)


## Award points for killing an enemy (called by whoever connects to enemy.died)
## enemy_type should be the enemy node to check if it's a PatrolEnemy
func award_enemy_kill(enemy: Node) -> void:
	if enemy is PatrolEnemy:
		add_points(POINTS_PATROL_ENEMY)
	else:
		add_points(POINTS_STATIONARY_ENEMY)
