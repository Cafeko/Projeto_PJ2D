extends Node2D
class_name Activable


# --- Vars ------------------------------------------------------------------- #
@export var activators_list : Array[Activator]
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	for activator in activators_list:
		activator.state_change.connect(_on_activator_state_change)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func active():
	pass


func inactive():
	pass


func check_activators_active():
	for activator in activators_list:
		if not activator.is_active():
			return false
	return true
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
func _on_activator_state_change():
	if check_activators_active():
		active()
	else:
		inactive()
# ---------------------------------------------------------------------------- #
