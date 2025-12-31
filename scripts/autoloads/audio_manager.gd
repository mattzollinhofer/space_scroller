extends Node
## AudioManager autoload - provides centralized audio control for music and sound effects.
## Manages background music, boss battle tracks, and SFX playback.

## Audio bus names
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

## Settings persistence path
const AUDIO_SETTINGS_PATH := "user://audio_settings.cfg"

## Music resources
var _gameplay_music: AudioStream = null

## Music player for gameplay music
var _music_player: AudioStreamPlayer = null

## State
var _is_muted: bool = false


func _ready() -> void:
	# Create music player node
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)

	# Preload music resources
	_preload_music()


func _preload_music() -> void:
	## Preload all music resources for quick playback
	# Try OGG first, fall back to WAV
	var ogg_path = "res://assets/audio/music/gameplay.ogg"
	var wav_path = "res://assets/audio/music/gameplay.wav"

	if ResourceLoader.exists(ogg_path):
		_gameplay_music = load(ogg_path)
	elif ResourceLoader.exists(wav_path):
		_gameplay_music = load(wav_path)


## Play background gameplay music
func play_music() -> void:
	if _gameplay_music and _music_player:
		_music_player.stream = _gameplay_music
		_music_player.play()


## Stop all music playback
func stop_music() -> void:
	if _music_player:
		_music_player.stop()


## Check if music is currently playing
func is_music_playing() -> bool:
	return _music_player and _music_player.playing
