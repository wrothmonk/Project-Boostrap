extends Node
class_name TemporalNode

var manager


func connect_manager(time_manager):
	manager = time_manager
	manager.connect_temporal_node(self)

func disconnect_manager():
	manager = null

func start_time_travel():
	pass

func stop_time_travel():
	pass

func _ready():
	# warning-ignore:return_value_discarded
	TimeTravelEvents.connect("connect_manager", self, "connect_manager")
	# warning-ignore:return_value_discarded
	TimeTravelEvents.connect("disconnect_manager", self, "disconnect_manager")
	# warning-ignore:return_value_discarded
	TimeTravelEvents.connect("start_time_travel", self, "start_time_travel")
	# warning-ignore:return_value_discarded
	TimeTravelEvents.connect("stop_time_travel", self, "stop_time_travel")

func record_data() -> Dictionary:
	return {} # This should be a dict filled out with relevant data by any inheriting script

# Recieve previously recorded temporal data and apply it
# Data will be in exact same form as returned by record_data
# warning-ignore:unused_argument
func apply_data(data: Dictionary):
	pass 
