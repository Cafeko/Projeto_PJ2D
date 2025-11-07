extends Node

class_name RecordingTape

# --- Signals ---------------------------------------------------------------- #
signal recording_timeout
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
var target_object : Node = null
var max_recording_time : float = 10.0
var current_recording_time : float = 10.0
var current_frame = 0
var recording_data = []
var finalized : bool = false
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _init(record_time_value:float, object:Node):
	max_recording_time = record_time_value
	target_object = object

func _ready():
	reset()

func _physics_process(_delta: float):
	pass
# ---------------------------------------------------------------------------- #
# --- Functions -------------------------------------------------------------- #
func reset():
	current_recording_time = max_recording_time
	current_frame = 0
	recording_data = []
	finalized = false

func add_recording_frame(time_passed:float):
	if finalized:
		return
	if current_recording_time <= 0.0:
		recording_timeout.emit()
		return
	if target_object and target_object.has_method("get_record_data"):
		recording_data.append(target_object.get_record_data())
	else:
		recording_data.append({})
	current_recording_time -= time_passed
	current_frame += 1

func restart_current_frame():
	current_frame = 0

func get_next_frame_data():
	if current_frame < len(recording_data):
		var data = recording_data[current_frame]
		current_frame += 1
		return data

func finalize():
	finalized = true
# ---------------------------------------------------------------------------- #
