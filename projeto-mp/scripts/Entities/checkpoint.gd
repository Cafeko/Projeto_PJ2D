extends Area2D
class_name Checkpoint

# --- Var -------------------------------------------------------------------- #
@export var interactable : Interactable
@export var recording_tape_number : int = 1

@onready var anim = $AnimatedSprite2D
var recorder : Recorder 
var ativado = false
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready():
	set_ativado(false)
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
# Muda o estado de ativado do checkpoint.
func set_ativado(valor:bool):
	ativado = valor
	_update_anim()


# Executada para botar checkpoint como o checkpoint atual do player.
func player_ativa_checkpoint(player:Player):
	player.update_checkpoint(self)
	_create_recorder(player)
	if not ativado:
		set_ativado(true)


# Executa quando player troca o checkpoint atual.
func player_desativa_checkpoint():
	if ativado:
		set_ativado(false)
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
func _update_anim():
	if ativado:
		anim.play("default")
	else:
		anim.play("unraised_flag")

func _create_recorder(player:Player):
	if recorder != null:
		recorder.queue_free()
	recorder = Recorder.new(player, recording_tape_number)
	add_child(recorder)
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
# Conecte o sinal "body_entered" a esta função
func _on_body_entered(body):
	if is_instance_of(body, Player):
		player_ativa_checkpoint(body)


func _on_body_exited(_body):
	pass


func _on_interaction(_kargs):
	if recorder:
		recorder.prepare_start_recording()
# ---------------------------------------------------------------------------- #
