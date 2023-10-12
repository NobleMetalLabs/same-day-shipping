#class_name Player
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_vec: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export_category("Player")

@export_range(0.1, 9.25, 0.05, "or_greater") var camera_sens: float = 3

var mouse_captured: bool = false
var look_dir_delta: Vector2 # Input direction for look/aim

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
var jump_velocity = -gravity_vec * sqrt(-2.0 * -gravity * jump_height) #vi = sqrt(vf^2 - 2gΔy)
@export var jump_time: float = 1 #s

@export var camera: Node3D

@onready var DEBUG_VECTORS : DEBUG_VECTORS = $"%DEBUG_VECTORS"

var look_dir : Vector3 :
	get:
		return Vector3.FORWARD\
			.rotated(Vector3.RIGHT, camera.rotation.x)\
			.rotated(Vector3.UP, self.rotation.y) 

var horizontal_velocity : Vector2 :
	get:
		return Vector2(self.velocity.x, self.velocity.z)
	set(value):
		self.velocity = Vector3(value.x, self.velocity.y, value.y)

func _ready() -> void:
	capture_mouse()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: look_dir_delta = event.relative * 0.01
	if Input.is_action_just_pressed("grapple"):
		attach_hook()
	#if Input.is_action_just_pressed("exit"): get_tree().quit()

func _physics_process(delta: float) -> void:
	if mouse_captured: _rotate_camera(delta)

	self.horizontal_velocity = get_new_horizontal_velocity(get_wish_dir(), delta)
	_jump()
	_gravity(delta)
	_slide()
	_hook(delta)
	print(look_dir)

	move_and_slide()

	DEBUG_VECTORS._set_dir("velocity_vec", self.velocity)
	DEBUG_VECTORS._set_dir("horiz_velocity_vec", Vector3(horizontal_velocity.x, 0, horizontal_velocity.y))

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(delta: float, sens_mod: float = 1.0) -> void:
	#look_dir += Input.get_vector("look_left","look_right","look_up","look_down")
	self.rotation.y -= look_dir_delta.x * camera_sens * sens_mod * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir_delta.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir_delta = Vector2.ZERO

var MAX_SPEED = 10
var MAX_ACCEL = 10 * MAX_SPEED
var MAX_AIR_SPEED = 1
func get_wish_dir() -> Vector2:
	var wish_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#I can't prove it, but this **feels** really fucking dumb
	wish_dir = Vector3(wish_dir.x, 0, wish_dir.y)
	wish_dir = self.transform.basis * wish_dir
	wish_dir = Vector2(wish_dir.x, wish_dir.z).normalized()
	DEBUG_VECTORS._set_dir("wish_dir", Vector3(wish_dir.x, 0, wish_dir.y))
	return wish_dir
	
func get_new_horizontal_velocity(wish_dir : Vector2, delta: float) -> Vector2:
	var vel = self.horizontal_velocity
	vel = friction(vel, delta)

	var current_speed = vel.dot(wish_dir)
	var add_speed = clampf((MAX_SPEED if is_on_floor() else MAX_AIR_SPEED) - current_speed, 0, MAX_ACCEL * delta)

	return vel + (add_speed * wish_dir)

var _was_on_floor : bool = true
func friction(vel, delta) -> Vector2:
	var _is_on_floor = self.is_on_floor()
	if _is_on_floor and _was_on_floor:
		return vel * (0.01 ** delta)
	_was_on_floor = _is_on_floor
	return vel

func _gravity(delta: float):
	velocity += gravity_vec * gravity * delta

func _jump():
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity += jump_velocity

func _slide():
	pass

var MAX_HOOK_SPEED : float = 10
var MAX_HOOK_ACCEL : float = 100

var is_hooked : bool = false
var hook_target : Vector3 = Vector3.ZERO
var hook_vel : Vector3 = Vector3.ZERO

func attach_hook():
	#if is_hooked: return
	var raycast : RayCast3D = self.find_child("grappling_hook_raycast")
	if not raycast.is_colliding(): return
	hook_target = raycast.get_collision_point()
	is_hooked = true
	
	##TODO: TRANSITION TO SUM OF ALL FORCES
func _hook(delta):
	if not is_hooked: return
	var target_dir : Vector3 = self.position.direction_to(hook_target)
	var current_speed = target_dir.length()
	var add_speed = clampf(MAX_HOOK_SPEED - current_speed, 0, MAX_HOOK_ACCEL * delta)

	hook_vel += (add_speed * target_dir)
	velocity += hook_vel
	DEBUG_VECTORS._set_dir("hook_target_dir", hook_target - self.position)
	DEBUG_VECTORS._set_dir("hook_motion_dir", hook_vel)


# func _slide():
# 	if Input.is_action_just_pressed("slide"):
# 		sliding = true
# 		print("slide!")
# 	elif Input.is_action_just_released("slide"):
# 		sliding = false
# 		print("no slide!")

# 	self.floor_stop_on_slope = not sliding
# 	self.floor_snap_length = sliding_snap_length if sliding else walking_snap_length
