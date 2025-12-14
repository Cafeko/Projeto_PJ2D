extends Area2D
class_name Interactable

@export var parent : Node2D

# --- Signals ---------------------------------------------------------------- #
signal interaction
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@export var can_interact_with : bool = true
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Emite sinal de interação e parametros caso necessario.
func interact(kargs:Dictionary = {}):
	if can_interact_with:
		interaction.emit(kargs)


# Muda se pode interagir com ou não.
func set_can_interact_with(value:bool):
	can_interact_with = value


# Retorna se pode interagir com ou não.
func get_can_interact_with():
	return can_interact_with
# ---------------------------------------------------------------------------- #
