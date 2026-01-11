extends Node
## FirebaseService autoload - provides centralized Firebase Realtime Database access.
## Handles score submission and retrieval via REST API with silent error handling.
## Design: 4-second timeout, silent failure, no retries, no offline queueing.

## Path to Firebase configuration file
const FIREBASE_CONFIG_PATH := "res://config/firebase_config.json"

## Firebase configuration
var _project_id: String = ""
var _database_url: String = ""

## HTTPRequest node for submit operations
var _submit_http_request: HTTPRequest = null

## HTTPRequest node for fetch operations
var _fetch_http_request: HTTPRequest = null

## Callback for fetch operation
var _fetch_callback: Callable = Callable()


func _ready() -> void:
	_load_config()
	_setup_http_requests()


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


## Setup HTTPRequest nodes for network operations
func _setup_http_requests() -> void:
	# Submit request node
	_submit_http_request = HTTPRequest.new()
	_submit_http_request.name = "SubmitHTTPRequest"
	_submit_http_request.timeout = 4.0  # 4-second timeout
	add_child(_submit_http_request)
	_submit_http_request.request_completed.connect(_on_submit_completed)

	# Fetch request node
	_fetch_http_request = HTTPRequest.new()
	_fetch_http_request.name = "FetchHTTPRequest"
	_fetch_http_request.timeout = 4.0  # 4-second timeout
	add_child(_fetch_http_request)
	_fetch_http_request.request_completed.connect(_on_fetch_completed)


## Submit a score to Firebase Realtime Database
## Fire-and-forget pattern - no callback, no await, silent failure
func submit_score(score: int, initials: String = "AAA") -> void:
	# Silent failure if database URL not configured
	if _database_url.is_empty():
		return

	# Silent failure if HTTP request is busy
	if not _submit_http_request or _submit_http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
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
	var error = _submit_http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		return  # Silent failure


## Handle submit request completion (silent - no user feedback)
func _on_submit_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# Silent handling - we don't care about the response
	# Success or failure, the game continues uninterrupted
	pass


## Fetch top scores from Firebase Realtime Database
## Calls callback with Array of dictionaries (empty array on error/timeout)
func fetch_top_scores(count: int = 10, callback: Callable = Callable()) -> void:
	# Store callback for later use
	_fetch_callback = callback

	# If count is 0 or negative, immediately return empty array
	if count <= 0:
		_call_fetch_callback([])
		return

	# Silent failure if database URL not configured
	if _database_url.is_empty():
		_call_fetch_callback([])
		return

	# Silent failure if HTTP request is busy
	if not _fetch_http_request or _fetch_http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_call_fetch_callback([])
		return

	# Build the request URL with query parameters
	# Firebase REST API: orderBy="score" and limitToLast to get top scores
	var url = '%s/scores.json?orderBy="score"&limitToLast=%d' % [_database_url, count]

	# Send the GET request
	var error = _fetch_http_request.request(url)
	if error != OK:
		_call_fetch_callback([])
		return


## Handle fetch request completion
func _on_fetch_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# Check for errors
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_call_fetch_callback([])
		return

	# Parse JSON response
	var json_text = body.get_string_from_utf8()
	if json_text.is_empty():
		_call_fetch_callback([])
		return

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		_call_fetch_callback([])
		return

	var data = json.get_data()

	# Handle null response (empty database)
	if data == null:
		_call_fetch_callback([])
		return

	# Firebase returns an object with keys, convert to array
	if not data is Dictionary:
		_call_fetch_callback([])
		return

	var scores: Array = []
	for key in data:
		var entry = data[key]
		if entry is Dictionary:
			scores.append({
				"score": entry.get("score", 0),
				"initials": entry.get("initials", "AAA")
			})

	# Sort descending by score (Firebase limitToLast returns ascending)
	scores.sort_custom(func(a, b): return a["score"] > b["score"])

	_call_fetch_callback(scores)


## Helper to safely call fetch callback
func _call_fetch_callback(scores: Array) -> void:
	if _fetch_callback.is_valid():
		_fetch_callback.call(scores)
	_fetch_callback = Callable()
