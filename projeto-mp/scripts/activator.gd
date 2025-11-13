extends Node2D
class_name Activator

# --- Signals ---------------------------------------------------------------- #
signal state_change
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@export var active : bool = false
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func activate():
	active = true
	state_change.emit()


func deactivate():
	active = false
	state_change.emit()


func is_active():
	return active


func invert_active():
	if is_active():
		deactivate()
	else:
		activate()
# ---------------------------------------------------------------------------- #
