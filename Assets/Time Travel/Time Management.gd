extends Node
class_name TimeManager

export var current_time: int = 0 # Time in centiseconds, in form of int for accuracy and consistency of indexing
export var save_frequency: int = 2
export var time_paused := false

var time_reversing := false
var reverse_timer: int = 0

var connected_nodes = []
var previous_save: int = 0
var time_indexes := []
var current_time_index: int = 0

func send_connect_signal():
	# Emit signal to trigger connections of all time-travel dependent nodes
	TimeTravelEvents.emit_signal("connect_manager", self)

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().get_root().connect("ready", self, "send_connect_signal", [], CONNECT_ONESHOT)

func _exit_tree():
	# Emit signal to have all connected nodes disconnect from this manager
	TimeTravelEvents.emit_signal("disconnect_manager")
	connected_nodes = []

# Called by connecting nodes after recieving "connect_manager" signal
func connect_temporal_node(temporal_node: TemporalNode):
	# TODO Optimization: turn this dictionary into a custom C++ module/datatype?
	var temporal_data = {
		"Node": temporal_node,
		# TODO Optimization: convert to custom module/datatype as above
		"coordinates": {} # Indexed by time stamps, values are data determined by each temporal node's script
	}
	connected_nodes.append(temporal_data)

func record_temporal_data(temporal_data: Dictionary):
	var temporal_node: TemporalNode = temporal_data.Node
	var data := temporal_node.record_data()
	temporal_data.coordinates[current_time] = data

func record_timeout():
	# Record the current time index
	time_indexes.append(current_time)
	current_time_index = len(time_indexes) - 1
	
	# Start up threads for recording each objects data
	var threads = []
	for temporal_data in connected_nodes:
		var thread = Thread.new()
		thread.start(self, "record_temporal_data", temporal_data)
		threads.append(thread)
#		record_temporal_data(temporal_data)

	# Wait until all threads finished
	for thread in threads:
		thread.wait_to_finish()

func apply_temporal_data(temporal_data: Dictionary):
	var temporal_node: TemporalNode = temporal_data.Node
	var data: Dictionary = temporal_data.coordinates[current_time]
	temporal_node.apply_data(data)

func _physics_process(delta: float):
	if not time_paused:
		var centi_delta := int(round(delta * 100))
		current_time = current_time + centi_delta
		if current_time - previous_save >= save_frequency:
			previous_save = current_time
			record_timeout()
			

	if time_reversing and Input.is_action_pressed("reverse_time") and current_time_index > 0:
		reverse_timer -= int(round(delta * 100))
		if reverse_timer <= 0:
			current_time_index = current_time_index - 1
			current_time = time_indexes[current_time_index]
			
#			# Start up threads for applying temporal data to each object
#			var threads = []
			for temporal_data in connected_nodes:
#				var thread = Thread.new()
#				thread.start(self, "apply_temporal_data", temporal_data)
#				threads.append(thread)
				apply_temporal_data(temporal_data)
#
#			# Wait until all threads are finished
#			for thread in threads:
#				thread.wait_to_finish()

			if current_time_index > 0:
				reverse_timer = current_time - time_indexes[current_time_index - 1]
		

func _input(event: InputEvent):
	if event.is_action_pressed("reverse_time") and time_paused == false:
		TimeTravelEvents.emit_signal("start_time_travel")
		time_paused = true
		time_reversing = true
		reverse_timer = current_time - time_indexes[current_time_index - 1]
	
	if event.is_action_released("reverse_time"):
		TimeTravelEvents.emit_signal("stop_time_travel")
		time_paused = false
		time_indexes.resize(current_time_index + 1)
		previous_save = current_time
