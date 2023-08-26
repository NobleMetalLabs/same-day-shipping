extends Label

@export var player : CharacterBody3D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.text = "SPEED: %3.3f" % [player.velocity.length()]
