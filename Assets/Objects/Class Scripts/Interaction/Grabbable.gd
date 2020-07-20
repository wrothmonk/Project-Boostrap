extends Interactable

class_name Grabbable

var held := false
var old_shape: Shape
var flag_remove_collision := false
var remove_collision_id: int

export var collision_path := NodePath("../CollisionShape")

onready var TargetCollision := get_node(collision_path) as CollisionShape
onready var TargetRigid := Target as RigidBody

func on_exit(body: Object):
	if flag_remove_collision and body.get_instance_id() == remove_collision_id:
		TargetRigid.remove_collision_exception_with(body)
		self.disconnect("body_exited", self, "on_exit")
		flag_remove_collision = false

func grab(Interactor: Player):
	# Disable physics
	TargetCollision.disabled = true
	TargetRigid.mode = 1 # Static mode
	TargetRigid.sleeping = true
	
	# Put in player's "hand"
	Interactor.HoldPoint.remote_path = TargetRigid.get_path()
	old_shape = TargetCollision.shape
	Interactor.Holder.HoldCollisionShape.shape = TargetCollision.shape
	TargetRigid.add_collision_exception_with(Interactor.Holder)
	Interactor.Holder.HoldCollisionShape.disabled = false
	Interactor.Holder.HeldObject = self
	
	held = true

func drop(Interactor: Player, impart_velocity := true):
	# Remove from player's "hand"
	Interactor.HoldPoint.remote_path = ""
	Interactor.Holder.HoldCollisionShape.shape = old_shape
	Interactor.Holder.HoldCollisionShape.disabled = true
	TargetRigid.remove_collision_exception_with(Interactor.Holder)
	Interactor.Holder.HeldObject = null
	
	# Re-enable physics
	TargetCollision.disabled = false
	TargetRigid.mode = 0 # Rigid mode
	TargetRigid.sleeping = false
	
	# Temporarily remove collision with the player if they drop inside themself
	if overlaps_body(Interactor):
		flag_remove_collision = true
		remove_collision_id = Interactor.get_instance_id()
		TargetRigid.add_collision_exception_with(Interactor)
		
		# warning-ignore:return_value_discarded
		self.connect("body_exited", self, "on_exit")
	
	if impart_velocity:
		TargetRigid.apply_central_impulse(Interactor.velocity)
	
	held = false

func interact(Interactor: Player):
	if not held:
		grab(Interactor)
	else:
		drop(Interactor)
