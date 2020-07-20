extends KinematicBody

class_name Player

export var head_path := NodePath("Head")
export var camera_path := NodePath("Head/PlayerCam")
export var hold_transform_path := NodePath("Head/PlayerCam/HoldPos/Holder/HoldTransform")
export var holder_path := NodePath("Head/PlayerCam/HoldPos/Holder")
export var gravity := Vector3(0, -9.81, 0)
export var floor_normal := Vector3.UP
export var max_speed: float = 7 # Meters/second
export var acceleration: float = 3 # Meters/second
export var decceleration: float = 7 # Meters/second
export var jump_force: float = 5 # Meters/second of instant acceleration
export var inertia: float = 1

var velocity: Vector3

onready var head := get_node(head_path) as Spatial
onready var camera := get_node(camera_path) as PlayerCam

# warning-ignore:unused_class_variable
onready var HoldPoint := get_node(hold_transform_path) as RemoteTransform
# warning-ignore:unused_class_variable
onready var Holder := get_node(holder_path) as KinematicBody

func _input(event):
	if event.is_action_pressed("Jump") and self.is_on_floor():
		velocity.y += jump_force

func _physics_process(delta: float):
	# Movement input handling
	var move_dir := Vector3(0, 0, 0)
	if camera.in_control:
		var head_basis := head.get_global_transform().basis as Basis
		if Input.is_action_pressed("move_forward"):
			move_dir += -head_basis.z
		elif Input.is_action_pressed("move_backward"):
			move_dir += head_basis.z
		if Input.is_action_pressed("move_left"):
			move_dir += -head_basis.x
		elif Input.is_action_pressed("move_right"):
			move_dir += head_basis.x
	
	move_dir = move_dir.normalized()
	var moving: bool = move_dir.length() > 0
	move_dir.y = velocity.y / max_speed # Prevents phantom vertical forces along y axis from interpolation
	
	if moving:
		velocity = velocity.linear_interpolate(move_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.linear_interpolate(move_dir * max_speed, decceleration * delta)
	
	# Physics calculations
	velocity += gravity * delta
	
	# Movement
	velocity = self.move_and_slide(velocity, floor_normal, true, 4, PI/4, false)
	
	# Collision handling
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider is RigidBody:
			var origin: Vector3 = collision.collider.global_transform.origin
			collision.collider.apply_impulse(collision.position - origin, -collision.normal * inertia)
