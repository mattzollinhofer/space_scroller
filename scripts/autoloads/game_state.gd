extends Node
## GameState autoload - stores session state including selected character.
## Resets to defaults on each game launch.

## Character identifiers
const CHARACTER_BLUE_BLASTER := "blue_blaster"
const CHARACTER_SPACE_DRAGON := "space_dragon"
const CHARACTER_COSMIC_CAT := "cosmic_cat"

## Default character on launch
const DEFAULT_CHARACTER := CHARACTER_BLUE_BLASTER

## Currently selected character for this session
var _selected_character: String = DEFAULT_CHARACTER

## Signal emitted when character selection changes
signal character_changed(character_id: String)


func _ready() -> void:
	# Reset to default on each launch
	_selected_character = DEFAULT_CHARACTER


## Get the currently selected character identifier
func get_selected_character() -> String:
	return _selected_character


## Set the selected character for this session
func set_selected_character(character_id: String) -> void:
	if character_id in [CHARACTER_BLUE_BLASTER, CHARACTER_SPACE_DRAGON, CHARACTER_COSMIC_CAT]:
		_selected_character = character_id
		character_changed.emit(character_id)
	else:
		push_warning("Invalid character ID: %s" % character_id)


## Get the texture path for a character
func get_character_texture_path(character_id: String) -> String:
	match character_id:
		CHARACTER_BLUE_BLASTER:
			return "res://assets/sprites/player.png"
		CHARACTER_SPACE_DRAGON:
			return "res://assets/sprites/space-dragon-1.png"
		CHARACTER_COSMIC_CAT:
			return "res://assets/sprites/cosmic-cat-1.png"
		_:
			return "res://assets/sprites/player.png"


## Get the display name for a character
func get_character_display_name(character_id: String) -> String:
	match character_id:
		CHARACTER_BLUE_BLASTER:
			return "Blue Blaster"
		CHARACTER_SPACE_DRAGON:
			return "Space Dragon"
		CHARACTER_COSMIC_CAT:
			return "Cosmic Cat"
		_:
			return "Unknown"


## Get all available characters
func get_all_characters() -> Array[String]:
	return [CHARACTER_BLUE_BLASTER, CHARACTER_SPACE_DRAGON, CHARACTER_COSMIC_CAT]
