class_name Player
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

@onready var camera: Node3D = self.find_child("camera")

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

var delta_time : float

func _physics_process(delta: float) -> void:
	delta_time = delta
	if mouse_captured: _rotate_camera()

	_state()
	_wish_dir()
	_hook()
	if not is_hooked:
		_friction()
		_gravity()
	_horizontal_velocity()
	_jump()
	_slide()

	move_and_slide()

	DEBUG_VECTORS.set_dir("velocity", self.velocity)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	self.rotation.y -= look_dir_delta.x * camera_sens * sens_mod * delta_time
	camera.rotation.x = clamp(camera.rotation.x - look_dir_delta.y * camera_sens * sens_mod * delta_time, -1.5, 1.5)
	look_dir_delta = Vector2.ZERO

var _is_on_floor : bool = false
var _was_on_floor : bool = false
var _is_just_on_floor : bool = false
var _is_on_floor_extended : bool = false
var _is_off_floor_extended : bool = false
func _state():
	_was_on_floor = _is_on_floor
	_is_on_floor = self.is_on_floor()
	_is_just_on_floor = _is_on_floor and not _was_on_floor
	_is_on_floor_extended = _is_on_floor and _was_on_floor
	_is_off_floor_extended = not _is_on_floor and not _was_on_floor

var wish_dir : Vector3

var MAX_SPEED = 7.5
var MAX_ACCEL = 10 * MAX_SPEED
var MAX_AIR_SPEED = 1.0
func _wish_dir():
	var wish_dir2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = Vector3(wish_dir2.x, 0, wish_dir2.y)
	wish_dir = self.transform.basis * wish_dir
	DEBUG_VECTORS.set_dir("wish_dir", wish_dir)

var STANDING_MOVEMENT_COEFF = 1
var SLIDING_MOVEMENT_COEFF = 0.1
var current_movement_coeff : float = STANDING_MOVEMENT_COEFF
func _horizontal_velocity():
	var vel = self.velocity
	var current_speed = vel.dot(wish_dir)
	var add_speed = clampf((MAX_SPEED if _is_on_floor else MAX_AIR_SPEED) - current_speed, 0, MAX_ACCEL * delta_time) #TODO: LESSEN SPEED GAIN FROM AIR STRAFING
	self.velocity = vel + (add_speed * wish_dir * current_movement_coeff)

var STANDING_FRICTION_COEFF = 0.01
var SLIDING_FRICTION_COEFF = 1.25
var SLIDING_TIME_TO_LERP_FRICTION = 3
var current_friction_coeff : float = STANDING_FRICTION_COEFF
func _friction():
	var vel = self.horizontal_velocity
	if _is_on_floor_extended:
		vel *= current_friction_coeff ** delta_time #TODO: REWORK FRICTION FOR MORE RESPONSIVE STOPPING FROM HIGH SPEEDS
	DEBUG_VECTORS.set_dir("friction", self.horizontal_velocity - vel)
	self.horizontal_velocity = vel

func _gravity():
	velocity += gravity_vec * gravity * delta_time

func _jump():
	if Input.is_action_just_pressed("jump") and _is_on_floor:
		velocity += jump_velocity

var is_hooked : bool = false
var hook_target : Vector3 = Vector3.ZERO
var hook_accelaration : Vector3 = Vector3.ZERO

func attach_hook():
	#if is_hooked: return
	var raycast : RayCast3D = self.find_child("grappling_hook_targeting_raycast")
	if not raycast.is_colliding(): return
	hook_target = raycast.get_collision_point()
	is_hooked = true

func detach_hook():
	is_hooked = false
	self.find_child("grappling_hook_obstruction_raycast").target_position = Vector3.ZERO

var HOOK_SPEED : float = 0
var MAX_HOOK_SPEED = 3.5 * MAX_SPEED
var MAX_HOOK_ACCEL = MAX_HOOK_SPEED / 2
func _hook():
	if not is_hooked: return
	var target_dir : Vector3 = self.position.direction_to(hook_target)
	HOOK_SPEED = self.velocity.dot(target_dir)
	if look_dir.dot(target_dir) < -0.25 \
	or MAX_HOOK_SPEED - HOOK_SPEED < 0.125 \
	or self.find_child("grappling_hook_obstruction_raycast").is_colliding(): 
		detach_hook()
		return

	var additional_hook_speed = clampf(MAX_HOOK_SPEED - HOOK_SPEED, 0, MAX_HOOK_ACCEL * delta_time)
	hook_accelaration = target_dir * additional_hook_speed
	velocity += hook_accelaration
	print(hook_target)
	print(self.basis * hook_target)
	self.find_child("grappling_hook_obstruction_raycast").target_position = self.to_local(hook_target) * 0.9

var is_sliding : bool = false
var slide_friction_tween : Tween
func _slide():
	if _is_on_floor:
		if Input.is_action_pressed("slide") and not is_sliding:
			is_sliding = true
			start_slide()
		elif not Input.is_action_pressed("slide") and is_sliding:
			is_sliding = false
			end_slide()
	else:
		is_sliding = false
		end_slide()


	self.floor_stop_on_slope = not is_sliding

func start_slide():
	current_movement_coeff = SLIDING_MOVEMENT_COEFF
	current_friction_coeff = SLIDING_FRICTION_COEFF
	slide_friction_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	slide_friction_tween.tween_property(self, "current_friction_coeff", STANDING_FRICTION_COEFF, SLIDING_TIME_TO_LERP_FRICTION)
	detach_hook()

func end_slide():
	current_movement_coeff = STANDING_MOVEMENT_COEFF
	current_friction_coeff = STANDING_FRICTION_COEFF
	if slide_friction_tween: slide_friction_tween.kill()