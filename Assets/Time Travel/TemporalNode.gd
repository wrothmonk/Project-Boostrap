extends Node
class_name TemporalNode

var manager


func connect_manager(time_manager):
	manager = time_manager
	manager.connect_temporal_node(self)

func disconnect_manager():
	manager = null

func record_data() -> Dictionary:
	return {} # This should be a dict filled out with relevant data by any inheriting script

func _ready():
# warning-ignore:return_value_discarded
	TimeTravelEvents.connect("connect_manager", self, "connect_manager")
# warning-ignore:return_value_discarded
	TimeTravelEvents.connect("disconnect_manager", self, "disconnect_manager")
	
	print("Connected ", self.get_parent().name, " to TimeTravelEvents")
