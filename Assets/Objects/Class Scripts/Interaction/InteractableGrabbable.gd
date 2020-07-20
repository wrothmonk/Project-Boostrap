extends Grabbable

class_name InteractGrab

export var pickup_delay: float = 0.3

var released := false
var timer: SceneTreeTimer

# warning-ignore:unused_argument
func interaction(Interactor: Player):
	pass

func interact(Interactor: Player):
	released = false
	if held:
		drop(Interactor)
	else:
		if not timer:
			timer = get_tree().create_timer(pickup_delay)
		
		yield(timer, "timeout")
		
		if timer:
			timer = null
		
			if not released and not held:
				grab(Interactor)

func interact_release(Interactor: Player):
	if held:
		pass
	else:
		timer.time_left = 0
		released = true
		interaction(Interactor)
