extends Label

@onready var player : Player = self.get_parent().get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = ""
	self.text += "SPEED: %3.3f\n" % [player.velocity.length()]
	self.text += "TIME: %3.3f\n" % [GameStopwatch.time]
