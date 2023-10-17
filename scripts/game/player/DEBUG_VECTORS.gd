class_name DEBUG_VECTORS
extends Node3D

@onready var player : Player = self.get_parent()

@export var velocity : RayCast3D
@export var friction : RayCast3D
@export var wish_dir : RayCast3D
@export var hook_target_dir : RayCast3D
@export var hook_motion_dir : RayCast3D

func set_dir(vec_name : String, vector : Variant):
	if vector is Vector2: vector = Vector3(vector.x, 0, vector.y)
	var ray = self.get(vec_name)
	if ray == null: return
	ray.target_position = vector * player.basis
