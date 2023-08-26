class_name Player 
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_vec: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export_category("Player")

@export_range(0.1, 9.25, 0.05, "or_greater") var camera_sens: float = 3

var mouse_captured: bool = false
var look_dir: Vector2 # Input direction for look/aim

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
var jump_velocity = -gravity_vec * sqrt(-2.0 * -gravity * jump_height) #vi = sqrt(vf^2 - 2gΔy)
@export var jump_time: float = 1 #s

@onready var camera: Node3D = $Camera

var horizontal_velocity : Vector2 :
	get:
		return Vector2(self.velocity.x, self.velocity.z)
	set(value):
		self.velocity = Vector3(value.x, self.velocity.y, value.y)

func _ready() -> void:
	capture_mouse()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	#if Input.is_action_just_pressed("exit"): get_tree().quit()

func _physics_process(delta: float) -> void:
	if mouse_captured: _rotate_camera(delta)

	self.horizontal_velocity = get_new_horizontal_velocity(get_wish_dir(), delta)
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

var MAX_SPEED = 10
var MAX_ACCEL = 10 * MAX_SPEED
var MAX_AIR_SPEED = 1
func get_wish_dir() -> Vector2:
	var wish_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = Vector3(wish_dir.x, 0, wish_dir.y)
	wish_dir = camera.transform.basis * wish_dir
	wish_dir = Vector2(wish_dir.x, wish_dir.z).normalized()
	print(wish_dir)
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
		return vel * (0.1 ** delta)
	_was_on_floor = _is_on_floor
	return vel

func _gravity(delta: float):
	velocity += gravity_vec * gravity * delta

func _jump():
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity += jump_velocity
