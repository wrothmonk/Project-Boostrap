extends Node
class_name TimeManager

var connected_nodes = []
export var current_time: int = 0 # Time in centiseconds, in form of int for accuracy and consistency of indexing
export var time_paused := false

func _ready():
	# Emit signal to trigger connections of all time-travel dependent nodes
	TimeTravelEvents.emit_signal("connect_manager", self)

func _exit_tree():
	# Emit signal to have all connected nodes disconnect from this manager
	TimeTravelEvents.emit_signal("disconnect_manager")
	connected_nodes = []

# Called by connecting nodes after recieving "connect_manager" signal
func connect_temporal_node(temporal_node: TemporalNode):
	# TODO Optimization: turn this dictionary into a custom C++ module/datatype?
	var temporal_data = {
		"Node": temporal_node,
		# TODO Optimization: convert to custom module/datatype
		"coordinates": {} # Indexed by time stamps, values are data determined by each temporal node's script
	}
	connected_nodes.append(temporal_data)

func _process(delta: float):
	if not time_paused:
		var centi_delta := int(round(delta * 100))
		current_time = current_time + centi_delta

func record_temporal_data(temporal_data: Dictionary):
	var temporal_node: TemporalNode = temporal_data.Node
	var data := temporal_node.record_data()
	temporal_data.coordinates[current_time] = data

func record_timeout():
	# Start up threads for recording each objects data
	var threads = []
	for temporal_data in connected_nodes:
		var thread = Thread.new()
		thread.start(self, "record_temporal_data", temporal_data)
		threads.append(thread)
	
	# Wait until all threads finished
	for thread in threads:
		thread.wait_to_finish()
