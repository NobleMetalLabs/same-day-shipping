#class_name UI
extends Control

@onready var new_game_panel : NewGamePanel = $"%NEW_GAME_PANEL"
@onready var countdown_panel : CountdownPanel = $"%COUNTDOWN_PANEL"

func _ready():
	print("ui ready")
	print(new_game_panel)
	print(countdown_panel)