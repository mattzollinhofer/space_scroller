extends Node
## FirebaseService autoload - provides centralized Firebase Realtime Database access.
## Handles score submission and retrieval via REST API with silent error handling.
## Design: 4-second timeout, silent failure, no retries, no offline queueing.

## Path to Firebase configuration file
const FIREBASE_CONFIG_PATH := "res://config/firebase_config.json"

## Firebase configuration
var _project_id: String = ""
var _database_url: String = ""

## HTTPRequest node for network operations
var _http_request: HTTPRequest = null


func _ready() -> void:
	_load_config()
	_setup_http_request()


## Load Firebase configuration from JSON file
func _load_config() -> void:
	if not FileAccess.file_exists(FIREBASE_CONFIG_PATH):
		return  # Silent failure - config missing is OK

	var file = FileAccess.open(FIREBASE_CONFIG_PATH, FileAccess.READ)
	if not file:
		return  # Silent failure

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		return  # Silent failure - malformed JSON

	var data = json.get_data()
	if data is Dictionary:
		_project_id = data.get("project_id", "")
		_database_url = data.get("database_url", "")


## Setup HTTPRequest node for network operations
func _setup_http_request() -> void:
	_http_request = HTTPRequest.new()
	_http_request.name = "HTTPRequest"
	_http_request.timeout = 4.0  # 4-second timeout
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


## Submit a score to Firebase Realtime Database
## Fire-and-forget pattern - no callback, no await, silent failure
func submit_score(score: int, initials: String = "AAA") -> void:
	# Silent failure if database URL not configured
	if _database_url.is_empty():
		return

	# Silent failure if HTTP request is busy
	if not _http_request or _http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return

	# Build the request URL
	var url = "%s/scores.json" % _database_url

	# Build the payload
	var timestamp = Time.get_unix_time_from_system()
	var payload = {
		"score": score,
		"initials": initials,
		"timestamp": int(timestamp)
	}
	var json_body = JSON.stringify(payload)

	# Set headers for JSON POST
	var headers = ["Content-Type: application/json"]

	# Send the request (fire-and-forget)
	var error = _http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		return  # Silent failure


## Handle HTTP request completion (silent - no user feedback)
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# Silent handling - we don't care about the response
	# Success or failure, the game continues uninterrupted
	pass
