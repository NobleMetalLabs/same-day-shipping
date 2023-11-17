class_name NewGamePanel
extends PopupPanel

signal new_game_requested(game_options : Dictionary)

@onready var dest_count_spinbox : SpinBox = $"%DEST_COUNT_SPINBOX"
@onready var seed_lineedit : LineEdit = $"%SEED_LINEEDIT"
@onready var start_button : Button = $"%START_BUTTON"

func _ready():
	start_button.pressed.connect(
		func():
			new_game_requested.emit(
				{
					"destination_count" : dest_count_spinbox.value,
					"seed" : seed_lineedit.text
				}
			)
			self.hide()
	)
