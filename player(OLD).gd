#class_name Player 
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_vec: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export var ground_accel: float = 100 # m/s^2
@export var air_accel: float = 50 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
var jump_velocity = -gravity_vec * sqrt(-2.0 * -gravity * jump_height) #vi = sqrt(vf^2 - 2gΔy)
@export var jump_time: float = 1 #s
@export_range(0.1, 9.25, 0.05, "or_greater") var camera_sens: float = 3

@export var walking_snap_length = 1
@export var sliding_snap_length = 1

var sliding: bool = false
var mouse_captured: bool = false



var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

@onready var camera: Node3D = $Camera

func _ready() -> void:
	capture_mouse()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	#if Input.is_action_just_pressed("exit"): get_tree().quit()

func _physics_process(delta: float) -> void:
	if mouse_captured: _rotate_camera(delta)

	_slide()
	_walk(delta)
	_jump()
	_gravity(delta)

	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(delta: float, sens_mod: float = 1.0) -> void:
	#look_dir += Input.get_vector("look_left","look_right","look_up","look_down")
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func _walk(delta: float):
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	printt(move_dir, is_on_floor(), velocity)
	var _forward: Vector3 = camera.transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	var motion_vec = walk_dir * speed * move_dir.length()
	if is_on_floor():
		velocity = velocity.move_toward(velocity + motion_vec, ground_accel * delta)
	else:
		var new_vel = velocity.move_toward(velocity + motion_vec, air_accel * delta)
		if velocity.length_squared() < new_vel.length_squared():
			velocity = new_vel

func _gravity(delta: float):
	velocity += gravity_vec * gravity * delta

func _jump():
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity += jump_velocity

func _slide():
	if Input.is_action_just_pressed("slide"):
		sliding = true
		print("slide!")
	elif Input.is_action_just_released("slide"):
		sliding = false
		print("no slide!")

	self.floor_stop_on_slope = not sliding
	self.floor_snap_length = sliding_snap_length if sliding else walking_snap_length
