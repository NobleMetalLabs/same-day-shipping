class_name EscapeMenu
extends Panel

@onready var newgame_button : Button = $"%NEWGAME-BUTTON"
@onready var restart_button : Button = $"%RESTART-BUTTON"
@onready var guides_button : Button = $"%GUIDES-BUTTON"
@onready var options_button : Button = $"%OPTIONS-BUTTON"
@onready var mainmenu_button : Button = $"%MAINMENU-BUTTON"

func _ready():
	newgame_button.pressed.connect(
		func():
			UI.new_game_panel.popup()
	)
	restart_button.pressed.connect(
		func():
			toggle_paused()
			GameStateManager.restart_game()
	)
	guides_button.pressed.connect(
		func():
			UI.guides_popup.popup()
	)
	options_button.pressed.connect(
		func():
			UI.settings_popup.popup()
	)
	mainmenu_button.pressed.connect(
		func():
			toggle_paused()
			get_tree().change_scene_to_file("res://scenes/MAINMENU.tscn")
	)

func _input(event):
	if get_tree().current_scene.name == "MAINMENU": return
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		toggle_paused()

func toggle_paused():
	var paused = !self.visible
	self.visible = paused
	get_tree().paused = paused
	if paused: UI.release_mouse()
	else: UI.capture_mouse()
