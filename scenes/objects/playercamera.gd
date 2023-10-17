class_name PlayerCameraBone
extends Node3D

@onready var player : Player = get_parent()

var sliding_height_drop = 0.5
var sliding_animation_time = 0.5
@onready var standing_camera_height = self.position.y
@onready var sliding_camera_height = standing_camera_height - sliding_height_drop
var do_i_know_player_is_sliding : bool = false

var tween : Tween

func _process(_delta):
	if player.is_sliding != do_i_know_player_is_sliding:
		if tween: tween.kill()
		if player.is_sliding:
			tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
			tween.tween_property(self, "position:y", sliding_camera_height, sliding_animation_time)
		else:
			tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
			tween.tween_property(self, "position:y", standing_camera_height, sliding_animation_time)
		do_i_know_player_is_sliding = player.is_sliding
