extends Control


# --- Vars ------------------------------------------------------------------- #
@export var label : Label
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	hide_timer()
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func set_time(time):
	if time is float:
		label.text = "%.2f" %time
	elif time is String:
		label.text = time


func display_timer():
	set_visible(true)


func hide_timer():
	set_visible(false)


func update_time(time):
	set_time(time)
# ---------------------------------------------------------------------------- #
