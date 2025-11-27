extends CanvasLayer

# --- Vars ------------------------------------------------------------------- #
@export var recording_timer : Control
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	global.set_ui(self)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Faz o timer da gravação de ações aparecer.
func display_recording_timer():
	recording_timer.display_timer()


# Faz o timer da gravação de ações desaparecer.
func hide_recording_timer():
	recording_timer.hide_timer()


# Atualiza o valor do timer da gravação de ações.
func update_recording_timer(time):
	if time == null or time < 0.0:
		time = 0.0
	recording_timer.update_time(time)
# ---------------------------------------------------------------------------- #
