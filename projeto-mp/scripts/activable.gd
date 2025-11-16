extends Node2D
class_name Activable

# --- Vars ------------------------------------------------------------------- #
@export var activators_list : Array[Activator]
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	for activator in activators_list:
		if is_instance_of(activator, Activator):
			activator.state_change.connect(_on_activator_state_change)
	update_state()
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Função abstrata, executada para deixar o activable ativo.
func active():
	pass # Substituir por implementação do activable ativo. 


# Função abstrata, executada para deixar o activable inativo.
func inactive():
	pass # Substituir por implementação do activable inativo.


# Verifica se todos os activators estão ativos.
func check_activators_active():
	for activator in activators_list:
		if is_instance_of(activator, Activator) and not activator.is_active():
			return false
	return true


# Adiva e desativa o ativavel de acordo com o estado dos ativadores.
func update_state():
	if check_activators_active():
		active()
	else:
		inactive()
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
# Executada quando o estado de um activator mudar;
# Verifica se deve ou não ativar o activable.
func _on_activator_state_change():
	update_state()
# ---------------------------------------------------------------------------- #
