extends Node

class_name Recorder

# --- Vars ------------------------------------------------------------------- #
@export_category("Nodes")
@export var timer : Timer
@export var player : CharacterBody2D
@export_category("Variables")

var player_copy = preload("res://entities/player_copy.tscn")

@onready var max_record_tapes : int = 3
var is_recording : bool = false
var is_playing_recording : bool = false
var recording_tapes = []
var player_copy_list = []
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready():
	# Conectar timer timeout a função de timeout.
	timer.timeout.connect(_on_timeout)
	global.start_recording.connect(_on_start_recording)
	global.finalize_recording.connect(_on_finalize_recording)
	global.play_recording.connect(_on_play_recording)

func _physics_process(_delta: float):
	if len(recording_tapes) > 0:
		var rt = recording_tapes[-1]
		print(rt.recording_data[-1], rt.current_recording_time)
# ---------------------------------------------------------------------------- #
# --- Record ----------------------------------------------------------------- #
func start_recording():
	var new_recording_tape = RecordingTape.new(10.0, player)
	new_recording_tape.recording_timeout.connect(_recording_time_out)
	if len(recording_tapes) > 0 and not recording_tapes[-1].finalized:
		recording_tapes.pop_back()
	if len(recording_tapes) >= max_record_tapes:
		recording_tapes.pop_front()
	recording_tapes.append(new_recording_tape)
	new_recording_tape.add_recording_frame(0.0)
	is_recording = true
	timer.start()

func _record():
	if len(recording_tapes) > 0:
		var recording_tape : RecordingTape  = recording_tapes[-1]
		recording_tape.add_recording_frame(timer.wait_time)
		timer.start()
# ---------------------------------------------------------------------------- #
# --- Play ------------------------------------------------------------------- #
func play_recording():
	for copy in player_copy_list:
		if copy:
			copy.queue_free()
	player_copy_list = []
	for i in range(len(recording_tapes)):
		if recording_tapes[i].finalized:
			recording_tapes[i].restart_current_frame()
			var copy = player_copy.instantiate()
			self.add_child(copy)
			var data = recording_tapes[i].get_next_frame_data()
			copy.global_position = data["position"]
			copy.current_anim = data["animation"]
			player_copy_list.append(copy)
		else:
			player_copy_list.append(null)
	is_playing_recording = true
	timer.start()

func _play():
	var tween = create_tween()
	for i in range(len(recording_tapes)):
		if recording_tapes[i].finalized:
			var data = recording_tapes[i].get_next_frame_data()
			var copy = player_copy_list[i]
			if copy != null and data != null:
				tween.tween_property(copy, "global_position", data["position"], timer.wait_time)
				copy.current_anim = data["animation"]
				copy.anim.flip_h = data["flip_h"]
	timer.start()
# -----------------dded----------------------------------------------------------- #
# --- On Signal -------------------------------------------------------------- #
func _on_start_recording(_checkpoin:Node):
	start_recording()

func _recording_time_out():
	is_recording = false
	recording_tapes.pop_back()

func _on_finalize_recording():
	_record()
	is_recording = false
	if len(recording_tapes) > 0:
		recording_tapes[-1].finalize()

func _on_play_recording():
	if len(recording_tapes) > 0:
		play_recording()

func _on_timeout():
	if is_recording:
		_record()
	if is_playing_recording:
		_play()
# ---------------------------------------------------------------------------- #
