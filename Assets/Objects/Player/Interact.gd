extends RayCast

export var player_path := NodePath("../../..")
onready var Player: Player = get_node(player_path)

var last_collider: Interactable

func _input(event: InputEvent):
	var Collider: Interactable
	if event.is_action_pressed("interact"):
		if last_collider and last_collider is Grabbable and last_collider.held:
			last_collider.interact(Player)
			last_collider = null
		else:
			Collider = get_collider()
			if Collider is Interactable:
				Collider.interact(Player)
				last_collider = Collider
	
	if event.is_action_released("interact"):
		if last_collider:
			last_collider.interact_release(Player)
