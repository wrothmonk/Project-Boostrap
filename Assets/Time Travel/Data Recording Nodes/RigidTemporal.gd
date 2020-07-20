extends TemporalNode
class_name RigidTemporal

export var rigid_body_path := NodePath("..")
onready var rigid_body := get_node(rigid_body_path) as RigidBody

var last_mode: int

#func start_time_travel():
#	rigid_body.set_mode(RigidBody.MODE_STATIC)
#	rigid_body.sleeping = true
#
#func stop_time_travel():
#	rigid_body.set_mode(RigidBody.MODE_RIGID)
#	rigid_body.sleeping = false

func record_data() -> Dictionary:
	var data = {
		"transform": rigid_body.global_transform,
		"linear_velocity": rigid_body.linear_velocity,
		"angular_velocity": rigid_body.angular_velocity,
		"mode": rigid_body.mode
	}
	
	return data

func apply_data(data):
	rigid_body.set_global_transform(data.transform)
	rigid_body.set_linear_velocity(data.linear_velocity)
	rigid_body.set_angular_velocity(data.angular_velocity)
