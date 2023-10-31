class_name PlayerGrappleLine
extends Line2D

@onready var player : Player = self.get_parent()

func _process(_delta):
	if not player.is_hooked:
		self.visible = false
		return
	self.visible = true

	self.points = [
		Vector2(
			get_viewport().size.x / 2,
			get_viewport().size.y,
		),
		player.camera.unproject_position(player.hook_target)
	]
