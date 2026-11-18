class_name FPSController
extends CharacterBody3D
## A reusable first-person character controller built on CharacterBody3D.
##
## Features:
## - Mouse look with configurable sensitivity and pitch limits.
## - Physics-based movement movement and jumping.
## - Smooth camera motion using physics interpolation.
## - Automatic mouse capture and release.
## - Separation of yaw and pitch using body and head pivots.
##
## Node Structure:
## FPSController
## └── BodyPivot
##     └── HeadPivot
##
## The BodyPivot node is detached from the CharacterBody3D at runtime and
## updated using the interpolated transform of the controller to provide
## smooth camera movement. Movement direction is calculated using the
## BodyPivot basis while the CharacterBody3D itself remains unrotated.
##
## Physics interpolation should be enabled in:
## Project Settings > Physics > Common > Physics Interpolation

@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.002
@export var look_down_limit: float = -85.0
@export var look_up_limit: float = 85.0
@export_group("Movement")
@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5

var body_yaw: float
var head_pitch: float
var _min_head_pitch: float
var _max_head_pitch: float

@onready var body_pivot: Node3D = $BodyPivot
@onready var head_pivot: Node3D = $BodyPivot/HeadPivot


func _enter_tree() -> void:
	# Cache the look up / down limits as radians.
	_min_head_pitch = deg_to_rad(look_down_limit)
	_max_head_pitch = deg_to_rad(look_up_limit)


func _ready() -> void:
	if not is_physics_interpolated_and_enabled():
		push_warning("FPSController is designed to work with physics
				interpolation enabled. Enable this in: Project Settings
				> Physics > Common. You may need to enable 'Advanced Settings'")
	
	# Assign current pivot rotations to prevent snapping to 0.
	body_yaw = body_pivot.rotation.y
	head_pitch = head_pivot.rotation.x
	
	# Separate the body_pivot transform from the parent to allow manual position
	# changes for smoother camera motion.
	body_pivot.top_level = true
	
	# Disable physics interpolation for the body_pivot (and its children) as
	# the position will be manually updated in _process().
	body_pivot.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	
	capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("ui_cancel"):
			release_mouse()
		
		if event is InputEventMouseMotion:
			_look_around(event)
		
		return
	
	if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
	):
		capture_mouse()


func _process(_delta: float) -> void:
	body_pivot.global_position = get_global_transform_interpolated().origin


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Set the direction using the input vector and the body_pivot basis.
	# CharacterBody3D will not be rotated.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right",
			"move_forward", "move_backward")
	var direction: Vector3 = (body_pivot.basis * Vector3(input_dir.x, 0,
			input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()


## Captures the mouse and enables look input.
func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Releases the mouse and disables look input.
func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Updates the controllers yaw and pitch from mouse motion input.
func _look_around(event: InputEventMouseMotion) -> void:
	# Get the relative mouse motion regardless of viewport scaling
	var viewport_transform: Transform2D = get_tree().root.get_final_transform()
	var mouse_motion: Vector2 = event.xformed_by(viewport_transform).relative
	
	mouse_motion *= mouse_sensitivity
	
	body_yaw -= mouse_motion.x
	body_yaw = wrapf(body_yaw, 0.0, TAU)
	
	head_pitch -= mouse_motion.y
	head_pitch = clampf(head_pitch, _min_head_pitch, _max_head_pitch)
	
	body_pivot.rotation.y = body_yaw
	head_pivot.rotation.x = head_pitch
