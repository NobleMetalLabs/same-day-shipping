class_name PackageZoneUIPoint
extends Control

@onready var camera = get_viewport().get_camera_3d()
@onready var parent = get_parent()

func _ready() -> void:
	if not parent is Node3D:
		push_error("The waypoint's parent node must inherit from Node3D.")

func _process(_delta):
	if not camera.current:
		# If the camera we have isn't the current one, get the current camera.
		camera = get_viewport().get_camera_3d()
	var parent_translation = parent.global_transform.origin
	var camera_transform = camera.global_transform
	var camera_translation = camera_transform.origin

	# We would use "camera.is_position_behind(parent_translation)", except
	# that it also accounts for the near clip plane, which we don't want.
	var is_behind = camera_transform.basis.z.dot(parent_translation - camera_translation) > 0

	# Fade the waypoint when the camera gets close.
	var distance = camera_translation.distance_to(parent_translation)
	modulate.a = clamp(remap(distance, 0, 2, 0, 1), 0, 1 )

	var unprojected_position = camera.unproject_position(parent_translation)

	position = unprojected_position
	visible = not is_behind
	return