#class_name UI
extends Control

@onready var escape_menu : EscapeMenu = $"%ESCAPE_MENU"
@onready var new_game_panel : NewGamePanel = $"%NEW_GAME_PANEL"
@onready var countdown_panel : CountdownPanel = $"%COUNTDOWN_PANEL"
@onready var win_panel : WinPanel = $"%WIN_PANEL"
@onready var practice_controls : Label = $"%PRACTICE_CONTROLS"
@onready var guides_popup : PopupPanel = $"%GUIDES_PANEL"
@onready var settings_popup : PopupPanel = $"%SETTINGS_POPUP"

@onready var cross_hair = $"%CROSSHAIR"

var mouse_captured : bool = false

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cross_hair.visible = true
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	cross_hair.visible = false
	mouse_captured = false
