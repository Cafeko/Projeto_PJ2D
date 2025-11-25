extends Node2D
class_name Activable

# --- Vars ------------------------------------------------------------------- #
@export var reverse_activable : bool = false
@export var activators_list : Array[Activator]

enum states {ACTIVE, INACTIVE}

var state : states
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	for activator in activators_list:
		if is_instance_of(activator, Activator):
			activator.state_change.connect(_on_activator_state_change)
	if reverse_activable:
		state = states.INACTIVE
	else:
		state = states.ACTIVE
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


# Adiva e desativa o ativavel de acordo com o estado dos ativadores;
# Se estiver invertido ele desativa quando os ativadores o ativarem.
func update_state():
	if not reverse_activable:
		if check_activators_active():
			_inactive_to_active()
		else:
			_active_to_inactive()
	else:
		if check_activators_active():
			_active_to_inactive()
		else:
			_inactive_to_active()


# Muda o estado de inativo para ativo.
func _inactive_to_active():
	if state == states.INACTIVE:
			active()
			state = states.ACTIVE


# Muda o estado de ativo para inativo.
func _active_to_inactive():
	if state == states.ACTIVE:
			inactive()
			state = states.INACTIVE
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
# Executada quando o estado de um activator mudar;
# Verifica se deve ou não ativar o activable.
func _on_activator_state_change():
	update_state()
# ---------------------------------------------------------------------------- #
