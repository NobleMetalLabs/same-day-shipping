class_name PlayerCollisionShape
extends CollisionShape3D

@onready var player : Player = get_parent()

var sliding_height_drop = 0.75
@onready var standing_collision_height = self.shape.height
@onready var sliding_collision_height = standing_collision_height - sliding_height_drop
var do_i_know_player_is_sliding : bool = false

var tween : Tween

func _process(_delta):
	if player.is_sliding != do_i_know_player_is_sliding:
		if player.is_sliding:
			self.shape.height = sliding_collision_height
			self.position.y = sliding_collision_height / 2
		else:
			self.shape.height = standing_collision_height
			self.position.y = standing_collision_height / 2
		do_i_know_player_is_sliding = player.is_sliding
