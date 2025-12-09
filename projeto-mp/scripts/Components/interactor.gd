extends Area2D
class_name Interactor
# --- Vars ------------------------------------------------------------------- #
var interactable_target : Interactable
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Interage com interagivel, caso tenha.
func do_interaction(kargs:Dictionary = {}):
	if interactable_target:
		interactable_target.interact(kargs)


# Muda o interagivel que vai interagir.
func set_interactable_target(target:Interactable):
	interactable_target = target


# Retorna o interagivel que está disponivel para interagir.
func get_interactable_target():
	return interactable_target

# Retorna o parente do interagivel alvo.
func get_interactable_target_parent():
	return interactable_target.parent
# ---------------------------------------------------------------------------- #
# --- On signal Funcs -------------------------------------------------------- #
# Detecta interagivel que entrar na area de interação.
func _on_area_entered(area: Area2D):
	if is_instance_of(area, Interactable):
		set_interactable_target(area)


# Retira o interagivel quando ele sair da area de interação.
func _on_area_exited(area: Area2D):
	if area == interactable_target:
		set_interactable_target(null)
# ---------------------------------------------------------------------------- #
