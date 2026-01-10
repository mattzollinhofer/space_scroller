extends Control
## Arcade-style 3-letter initials entry component.
## Used for entering player initials when achieving a high score.
## Supports keyboard navigation: up/down to cycle letters, left/right to move slots.
## Emits initials_confirmed signal when player confirms with Enter/Space.

## Emitted when player confirms their initials
signal initials_confirmed(initials: String)

## The three letter slots (0-25 for A-Z)
var _letters: Array[int] = [0, 0, 0]

## Currently selected slot (0, 1, or 2)
var _current_slot: int = 0

## Whether input is enabled
var _input_enabled: bool = false

## Gold color for selected slot
const COLOR_SELECTED: Color = Color(1, 0.84, 0, 1)

## White color for unselected slots
const COLOR_UNSELECTED: Color = Color(1, 1, 1, 1)

## References to letter labels
@onready var _letter_labels: Array[Label] = [
	$HBoxContainer/Slot0/LetterLabel,
	$HBoxContainer/Slot1/LetterLabel,
	$HBoxContainer/Slot2/LetterLabel
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_display()


func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled:
		return

	if event is InputEventKey and event.pressed:
		var handled: bool = false

		match event.keycode:
			KEY_UP, KEY_W:
				_cycle_letter(1)
				handled = true
			KEY_DOWN, KEY_S:
				_cycle_letter(-1)
				handled = true
			KEY_LEFT, KEY_A:
				_move_slot(-1)
				handled = true
			KEY_RIGHT, KEY_D:
				_move_slot(1)
				handled = true
			KEY_ENTER, KEY_SPACE:
				_confirm()
				handled = true

		if handled:
			get_viewport().set_input_as_handled()
			_play_sfx("button_click")


## Cycle the current slot's letter by the given amount (1 for up, -1 for down)
func _cycle_letter(direction: int) -> void:
	_letters[_current_slot] = (_letters[_current_slot] + direction + 26) % 26
	_update_display()


## Move to a different slot
func _move_slot(direction: int) -> void:
	_current_slot = (_current_slot + direction + 3) % 3
	_update_display()


## Confirm the initials entry
func _confirm() -> void:
	_input_enabled = false
	initials_confirmed.emit(get_initials())


## Update the visual display of all letters and highlighting
func _update_display() -> void:
	for i in range(3):
		if _letter_labels[i]:
			# Update the letter character
			_letter_labels[i].text = char(ord("A") + _letters[i])
			# Update highlighting
			if i == _current_slot:
				_letter_labels[i].add_theme_color_override("font_color", COLOR_SELECTED)
			else:
				_letter_labels[i].add_theme_color_override("font_color", COLOR_UNSELECTED)


## Get the current 3-letter initials string
func get_initials() -> String:
	return char(ord("A") + _letters[0]) + char(ord("A") + _letters[1]) + char(ord("A") + _letters[2])


## Show the entry UI and enable input
func show_entry() -> void:
	visible = true
	_input_enabled = true
	_current_slot = 0
	_letters = [0, 0, 0]
	_update_display()


## Hide the entry UI and disable input
func hide_entry() -> void:
	visible = false
	_input_enabled = false


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
