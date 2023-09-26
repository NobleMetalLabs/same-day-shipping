class_name WorldMover
extends Node3D

@export var target_name : StringName = ""
@export var movement_vector : Vector3 = Vector3.ZERO
var start_position
@export var rotation_vector : Vector3 = Vector3.ZERO
var start_rotation
@export var travel_back_to_start : bool = false
@export var linear : bool = false
@export var movement_time : float
@export var wait_time : float

var tween : Tween

func _ready():
	var target = find_child(target_name) if target_name != "" else self
	start_position = target.position
	start_rotation = target.rotation

	rotation_vector = deg_to_rad(1) * rotation_vector

	tween = get_tree().create_tween().bind_node(target).set_trans(Tween.TRANS_LINEAR if linear else Tween.TRANS_SINE)

	tween.tween_property(target, "position", start_position + movement_vector, movement_time)
	tween.parallel().tween_property(target, "rotation", start_rotation + rotation_vector, movement_time)

	tween.tween_interval(wait_time)

	tween.tween_property(target, "position", start_position, movement_time if travel_back_to_start else 0.0)
	tween.parallel().tween_property(target, "rotation", start_rotation, movement_time if travel_back_to_start else 0.0)
	
	tween.tween_interval(wait_time)
	tween.set_loops()
	
