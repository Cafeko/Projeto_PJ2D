extends RigidBody2D
class_name Item

# --- Vars ------------------------------------------------------------------- #
@export var usable : bool = true
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Retorna  se item é usavel.
func is_usable():
	return usable


# Função abstrata, executada quando player usar o item. 
func use_item():
	pass # Substituir por implementação de item sendo usado.
# ---------------------------------------------------------------------------- #
