class_name ResetPlane
extends Area3D

@export var reset_point : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(
		func(body):
			body.position = reset_point.position
	)


