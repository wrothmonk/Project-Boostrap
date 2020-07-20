extends Spatial

class_name PlayerCam

export var in_control := true
export var being_controlled := false
export var x_sensitivity := 0.2
export var y_sensitivity := 0.2
export var x_invert := false
export var y_invert := false
# warning-ignore:unused_class_variable
export var camera_path := NodePath(".")
export var head_path := NodePath("..")

onready var camera := self
onready var head := get_node(head_path) as Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if x_invert:
		x_sensitivity = -x_sensitivity
	if y_invert:
		y_sensitivity = -y_sensitivity

func _notification(notif):
	if notif == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if not being_controlled:
			in_control = true

func _input(event):
	if in_control and event is InputEventMouseMotion:
		var mouse := event.relative as Vector2
		
		var y_delta: float = mouse.y * -y_sensitivity
		if camera.rotation_degrees.x + y_delta > 90:
			y_delta = 90 - camera.rotation_degrees.x
		elif camera.rotation_degrees.x + y_delta < -90:
			 y_delta = -90 - camera.rotation_degrees.x
		
		head.rotate_y(deg2rad(mouse.x * -x_sensitivity))
		camera.rotate_x(deg2rad(y_delta))
		
	elif in_control and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		in_control = false
	
	elif not in_control and event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if not being_controlled:
			in_control = true
