extends InfoBox

@export var pages_list : Array[Control]


@onready var recording_label : Label = $Control/RecordingPage/Label
@onready var recording_warning : Label = $Control/RecordingPage/Label2
@onready var play_label : Label = $Control/PlayPage/Label
var current_recordings : int = 0
var max_recordings : int = 0
var recording_max_time : float = 0.00


func _ready():
	set_page_visible(-1)


# Deixa apenas a pagina referente ao index indicado visivel.
func set_page_visible(page_index:int):
	for i in range(len(pages_list)):
		if i == page_index:
			pages_list[i].set_deferred("visible", true)
		else:
			pages_list[i].set_deferred("visible", false)


# Atualiza os valores guardados e os textos. 
func update_infos(recording_n:int=0, max_recording_n:int=0, max_time:float=0.0):
	current_recordings = recording_n
	max_recordings = max_recording_n
	recording_max_time = max_time
	update_labels()


# Atualiza os textos com os valores guardados.
func update_labels():
	# Recording label:
	var recording_label_text = "Fitas: %d/%d\nTempo de gravação: %.2f" % [current_recordings, max_recordings, recording_max_time]
	recording_label.text = recording_label_text
	# Recording Warning:
	recording_warning.set_deferred("visible", current_recordings >= max_recordings)
	# Play lbel:
	var play_label_text = "Play %d gravações" %current_recordings
	play_label.text = play_label_text
