class_name CountdownPanel
extends Panel

@onready var timer : Timer = $timer
@onready var label : Label = $"%NUMBER_LABEL"

var count : int = 0

signal countdown_finished

func _ready():
	timer.timeout.connect(tick_down)
	self.hide()

func start_countdown(seconds : int = 3):
	self.show()
	count = seconds
	tick_down()

func tick_down():
	if count == 0:
		countdown_finished.emit()
		self.hide()
	else:
		label.text = str(count)
		timer.start()
		count -= 1
