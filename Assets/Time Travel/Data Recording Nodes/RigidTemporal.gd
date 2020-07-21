extends TemporalNode
class_name RigidTemporal

export var rigid_body_path := NodePath("..")
onready var rigid_body := get_node(rigid_body_path) as RigidBody

func start_time_travel():
	rigid_body.custom_integrator = true
#	rigid_body.sleeping = true
#	rigid_body.mode = RigidBody.MODE_KINEMATIC
#
func stop_time_travel():
	rigid_body.custom_integrator = false
#	rigid_body.sleeping = false
#	rigid_body.mode = RigidBody.MODE_RIGID

func record_data() -> Dictionary:
	var data = {
		"transform": rigid_body.global_transform,
#		"linear_velocity": rigid_body.linear_velocity,
#		"angular_velocity": rigid_body.angular_velocity
		"physics_state": PhysicsServer.body_get_direct_state(rigid_body.get_rid())
	}
	
	return data

func apply_data(data):
	rigid_body._integrate_forces(data.physics_state)
	rigid_body.set_global_transform(data.transform)
#	rigid_body.set_linear_velocity(data.linear_velocity)
#	rigid_body.set_angular_velocity(data.angular_velocity)
