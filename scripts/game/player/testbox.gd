extends RigidBody3D

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if not event is InputEventMouseButton: return
	event = event as InputEventMouseButton
	if event.button_index != MOUSE_BUTTON_LEFT: return
	throw = true

var throw : bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if throw:
		self.position = player.camera.global_position
		self.linear_velocity = player.look_dir * 25
		self.rotation = player.camera.rotation + player.rotation
		self.angular_velocity = Vector3.ZERO
		throw = false
