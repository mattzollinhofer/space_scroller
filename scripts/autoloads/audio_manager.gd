extends Node
## AudioManager autoload - provides centralized audio control for music and sound effects.
## Manages background music, boss battle tracks, and SFX playback.

## Audio bus names
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

## Settings persistence path
const AUDIO_SETTINGS_PATH := "user://audio_settings.cfg"

## Crossfade duration in seconds
const CROSSFADE_DURATION := 1.0

## Music resources
var _gameplay_music: AudioStream = null
var _boss_music: Dictionary = {}  # level_number -> AudioStream

## Music players (two for crossfade)
var _music_player_a: AudioStreamPlayer = null
var _music_player_b: AudioStreamPlayer = null
var _active_music_player: AudioStreamPlayer = null

## Current tween for crossfade animations
var _crossfade_tween: Tween = null

## State
var _is_muted: bool = false
var _is_boss_music_playing: bool = false


func _ready() -> void:
	# Create music player A (primary)
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.name = "MusicPlayerA"
	_music_player_a.bus = MUSIC_BUS
	add_child(_music_player_a)

	# Create music player B (secondary for crossfade)
	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.name = "MusicPlayerB"
	_music_player_b.bus = MUSIC_BUS
	add_child(_music_player_b)

	# Set initial active player
	_active_music_player = _music_player_a

	# Preload music resources
	_preload_music()


func _preload_music() -> void:
	## Preload all music resources for quick playback
	# Try OGG first, fall back to WAV for gameplay music
	var ogg_path = "res://assets/audio/music/gameplay.ogg"
	var wav_path = "res://assets/audio/music/gameplay.wav"

	if ResourceLoader.exists(ogg_path):
		_gameplay_music = load(ogg_path)
	elif ResourceLoader.exists(wav_path):
		_gameplay_music = load(wav_path)

	# Preload boss music tracks (one per level)
	for level in [1, 2, 3]:
		var boss_ogg = "res://assets/audio/music/boss_%d.ogg" % level
		var boss_wav = "res://assets/audio/music/boss_%d.wav" % level

		if ResourceLoader.exists(boss_ogg):
			_boss_music[level] = load(boss_ogg)
		elif ResourceLoader.exists(boss_wav):
			_boss_music[level] = load(boss_wav)


## Play background gameplay music
func play_music() -> void:
	if _gameplay_music and _active_music_player:
		_active_music_player.stream = _gameplay_music
		_active_music_player.volume_db = 0.0
		_active_music_player.play()
		_is_boss_music_playing = false


## Stop all music playback
func stop_music() -> void:
	_stop_crossfade_tween()
	if _music_player_a:
		_music_player_a.stop()
	if _music_player_b:
		_music_player_b.stop()
	_is_boss_music_playing = false


## Check if music is currently playing
func is_music_playing() -> bool:
	var a_playing = _music_player_a and _music_player_a.playing
	var b_playing = _music_player_b and _music_player_b.playing
	return a_playing or b_playing


## Check if boss music is currently playing
func is_boss_music_playing() -> bool:
	return _is_boss_music_playing


## Crossfade from current music to boss battle music for specified level
func crossfade_to_boss_music(level_number: int) -> void:
	if not level_number in _boss_music:
		push_warning("No boss music found for level %d" % level_number)
		return

	var boss_track = _boss_music[level_number]
	if not boss_track:
		return

	# Determine which player is currently active and which to crossfade to
	var current_player = _active_music_player
	var next_player = _music_player_b if _active_music_player == _music_player_a else _music_player_a

	# Stop any existing crossfade
	_stop_crossfade_tween()

	# Setup next player with boss music
	next_player.stream = boss_track
	next_player.volume_db = -80.0  # Start silent
	next_player.play()

	# Create crossfade tween
	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)

	# Fade out current player
	_crossfade_tween.tween_property(current_player, "volume_db", -80.0, CROSSFADE_DURATION)

	# Fade in next player
	_crossfade_tween.tween_property(next_player, "volume_db", 0.0, CROSSFADE_DURATION)

	# Update state
	_active_music_player = next_player
	_is_boss_music_playing = true

	# Stop the faded-out player after crossfade completes
	_crossfade_tween.chain().tween_callback(func(): current_player.stop())


## Crossfade from boss music back to gameplay music
func crossfade_to_gameplay_music() -> void:
	if not _gameplay_music:
		return

	# Determine which player is currently active and which to crossfade to
	var current_player = _active_music_player
	var next_player = _music_player_b if _active_music_player == _music_player_a else _music_player_a

	# Stop any existing crossfade
	_stop_crossfade_tween()

	# Setup next player with gameplay music
	next_player.stream = _gameplay_music
	next_player.volume_db = -80.0  # Start silent
	next_player.play()

	# Create crossfade tween
	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)

	# Fade out current player
	_crossfade_tween.tween_property(current_player, "volume_db", -80.0, CROSSFADE_DURATION)

	# Fade in next player
	_crossfade_tween.tween_property(next_player, "volume_db", 0.0, CROSSFADE_DURATION)

	# Update state
	_active_music_player = next_player
	_is_boss_music_playing = false

	# Stop the faded-out player after crossfade completes
	_crossfade_tween.chain().tween_callback(func(): current_player.stop())


## Stop any running crossfade tween
func _stop_crossfade_tween() -> void:
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
	_crossfade_tween = null
