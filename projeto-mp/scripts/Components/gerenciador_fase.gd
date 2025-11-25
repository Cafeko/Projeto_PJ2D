extends Node
class_name GerenciadorFase

# --- Vars ------------------------------------------------------------------- #
@export var fases_parent : Node2D
@export var fases : Array[Fase]

var current_fase : Fase
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	global.update_current_fase.connect(_on_update_current_fase)
	global.reset_current_fase.connect(_on_reset_current_fase)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Faz o processo de resetar a fase.
func reset_fase(fase:Fase):
	# Carrega informações da fase.
	var infos = fase.return_info_fase()
	# Load cena da fase.
	var new_fase_load = load(infos["path"])
	# Apaga fase.
	fase.queue_free()
	# Cria instancia da cena e posiciona no local correto.
	var new_fase = new_fase_load.instantiate()
	fases_parent.add_child(new_fase)
	new_fase.global_position = infos["position"]
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
func _on_reset_current_fase():
	reset_fase(current_fase)


func _on_update_current_fase(fase:Fase):
	current_fase = fase
# ---------------------------------------------------------------------------- #
