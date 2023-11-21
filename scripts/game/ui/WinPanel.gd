class_name WinPanel
extends Panel

@onready var text : Label = $"%TEXT"
@onready var timer : Timer = $"%TIMER"

signal finished()

func _ready():
	timer.timeout.connect(
		func(): 
			self.hide()
			finished.emit()
	)

func display_time(time : float):
	text.text = "You delivered all packages in %3.3f." % [time]
	self.show()
	timer.start()
