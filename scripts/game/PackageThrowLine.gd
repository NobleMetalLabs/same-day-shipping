class_name PackageThrowLine
extends Node

@onready var player : Player = get_parent()

var preview_line := MeshInstance3D.new()
var preview_line_mesh := ImmediateMesh.new()
var preview_line_material := ORMMaterial3D.new()

func _ready():
	preview_line.mesh = preview_line_mesh
	preview_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	preview_line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	preview_line_material.albedo_color = Color.WHITE

	preview_line.position = player.camera.position
	self.add_child(preview_line)

var VEL_IMPULSE = 30

func gen_points(throw_dir : Vector3):
	return [Vector3.RIGHT + Vector3.DOWN, throw_dir]

func _process(_delta):
	preview_line_mesh.clear_surfaces()
	preview_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES, preview_line_material)
	for point in gen_points(player.look_dir.rotated(Vector3.UP, -player.rotation.y)):
		preview_line_mesh.surface_add_vertex(point)
	preview_line_mesh.surface_end()
