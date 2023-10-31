class_name StartZone
extends Area3D

func _ready():
	self.body_exited.connect(func(_b):
		GameStopwatch.start()
	)
