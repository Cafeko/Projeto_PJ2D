extends Node2D
class_name Activator

# --- Signals ---------------------------------------------------------------- #
signal state_change
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@export var active : bool = false
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Muda o estado do activator para ativo.
func activate():
	active = true
	state_change.emit()


# Muda o estado do activator para inativo.
func deactivate():
	active = false
	state_change.emit()


# Retorna se o activator está ou não ativado.
func is_active():
	return active


# Inverte o estado do ativador, ativo para inativo e vise-versa.
func invert_active():
	if is_active():
		deactivate()
	else:
		activate()
# ---------------------------------------------------------------------------- #
