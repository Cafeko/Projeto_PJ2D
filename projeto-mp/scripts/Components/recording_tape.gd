extends Node
class_name RecordingTape

# --- Vars ------------------------------------------------------------------- #
var target_object : Node = null
var current_frame = 0
var recording_data = []
var finalized : bool = false
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _init(object:Node):
	target_object = object

func _ready():
	reset()

func _physics_process(_delta: float):
	pass
# ---------------------------------------------------------------------------- #
# --- Functions -------------------------------------------------------------- #
func reset():
	current_frame = 0
	recording_data = []
	finalized = false


func add_recording_frame():
	if finalized:
		return
	if target_object and target_object.has_method("get_record_data"):
		recording_data.append(target_object.get_record_data())
	else:
		recording_data.append({})
	current_frame += 1


# Volta frame atual para o inicio.
func restart_current_frame():
	current_frame = 0


# Obtem dados do frame atual e avança para o proximo frame.
func get_and_play_frame_data():
	if current_frame < len(recording_data):
		var data = recording_data[current_frame]
		current_frame += 1
		return data


# Obtem dados do proximo frame, sem avançar para o proximo.
func get_next_frame_data():
	var next_frame = current_frame + 1
	if next_frame < len(recording_data):
		var data = recording_data[next_frame]
		return data


func finalize():
	finalized = true


func in_tape_end():
	return current_frame >= len(recording_data)
# ---------------------------------------------------------------------------- #
