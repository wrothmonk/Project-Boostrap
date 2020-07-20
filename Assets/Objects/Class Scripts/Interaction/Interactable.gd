extends Area
class_name Interactable

export var target_path := NodePath("..")
# warning-ignore:unused_class_variable
onready var Target = get_node(target_path)

# warning-ignore:unused_argument
func interact(interactor):
	pass

# warning-ignore:unused_argument
func interact_release(interactor):
	pass
