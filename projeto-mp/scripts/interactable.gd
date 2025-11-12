extends Area2D
class_name Interactable

# --- Signals ---------------------------------------------------------------- #
signal interaction
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@export var can_interact_with : bool = true
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func interact(kargs:Dictionary = {}):
	if can_interact_with:
		interaction.emit(kargs)


func set_can_interact_with(value:bool):
	can_interact_with = value


func get_can_interact_with():
	return can_interact_with
# ---------------------------------------------------------------------------- #
