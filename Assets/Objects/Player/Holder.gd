extends KinematicBody

var HeldObject: Grabbable

export var snap_speed: float = 5
export var max_snap_speed: float = 5
export var max_distance: float = 3.4
export var player_path := NodePath("../../../..")
export var collision_shape_path := NodePath("CollisionShape")
export var hold_target_pos_path := NodePath("..")

onready var Player := get_node(player_path) as Player
onready var TargetHoldPos := get_node(hold_target_pos_path) as Spatial

# warning-ignore:unused_class_variable
onready var HoldCollisionShape := get_node(collision_shape_path) as CollisionShape

func _ready():
	self.add_collision_exception_with(Player)

func _physics_process(delta: float):
	if HeldObject:
		var pos: Vector3 = self.global_transform.origin
		var target_pos: Vector3 = TargetHoldPos.global_transform.origin
		var local_dir: Vector3 = target_pos - pos
		var distance: float = pos.distance_to(Player.global_transform.origin)
		
		if distance > max_distance:
			HeldObject.drop(Player, false)
			self.translation = Vector3.ZERO
			
		else:
			var target_vector: Vector3 = local_dir * snap_speed * delta
			if target_vector.length() > max_snap_speed:
				target_vector = target_vector.normalized() * max_snap_speed * delta
			if target_vector.length() > local_dir.length():
				target_vector = local_dir
		
			# warning-ignore:return_value_discarded
			move_and_collide(target_vector, false)
