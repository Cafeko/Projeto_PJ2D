extends Area2D
class_name Checkpoint

# --- Var -------------------------------------------------------------------- #
@export var interactable : Interactable
@export var recording_tape_number : int = 1
@export var recording_time : float = 10.0
@export var frame_time : float = 0.01

enum modes {PLAY, RECORD_AND_PLAY, STOP}

@onready var anim = $AnimatedSprite2D
var recorder : Recorder
var ativado = false
var mode : modes = modes.PLAY
var ui : CanvasLayer
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready():
	set_ativado(false)
	global.player_died.connect(_on_player_died)
	ui = global.get_ui()

#func _physics_process(_delta: float):
	#_display_timer()
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
# Muda o estado de ativado do checkpoint.
func set_ativado(valor:bool):
	ativado = valor
	_update_anim()


# Executada para botar checkpoint como o checkpoint atual do player.
func player_ativa_checkpoint(player:Player):
	player.update_checkpoint(self)
	if not ativado:
		_create_recorder(player)
		set_ativado(true)


# Executa quando player troca o checkpoint atual.
func player_desativa_checkpoint():
	if ativado:
		set_ativado(false)
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
# Atuliza animação do checkpoint.
func _update_anim():
	if ativado:
		anim.play("default")
	else:
		anim.play("unraised_flag")


# Cria e prepara recorder.
func _create_recorder(player:Player):
	if recorder != null:
		recorder.queue_free()
	recorder = Recorder.new(player, recording_tape_number, recording_time, frame_time)
	recorder.recording_timeout.connect(_display_timer)
	recorder.frame_timer.timeout.connect(_display_timer)
	add_child(recorder)
	recorder.recording_canceled.connect(_on_recording_canceled)


# Muda modo de execução do recorder.
func _set_mode(new_mode:modes):
	mode = new_mode
	if mode == modes.PLAY:
		print("PLay")
	elif mode == modes.RECORD_AND_PLAY:
		print("PLay and Record")
	elif mode == modes.STOP:
		print("Stop")


# Executa de acordo com o modo atual.
func _execute_mode():
	if mode == modes.PLAY:
		recorder.stop_recording()
		recorder.stop_playing()
		recorder.prepare_to_play()
		ui.display_recording_timer()
		ui.update_recording_timer(recorder.get_current_record_time())
	elif mode == modes.RECORD_AND_PLAY:
		recorder.prepare_to_record()
		recorder.prepare_to_play()
		ui.display_recording_timer()
		ui.update_recording_timer(recorder.get_current_record_time())
	elif mode == modes.STOP:
		recorder.stop_recording()
		recorder.stop_playing()
		ui.hide_recording_timer()
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
func _on_body_entered(body):
	if is_instance_of(body, Player):
		player_ativa_checkpoint(body)


func _on_recording_canceled():
	_set_mode(modes.STOP)
	_execute_mode()


func _on_player_died():
	if recorder:
		recorder.player_died()
		_set_mode(modes.STOP)
		ui.update_recording_timer(recorder.get_current_record_time())


# Atualiza o tempo na tela.
func _display_timer():
	if recorder:
		#if recorder.get_is_recording() or recorder.get_is_playing_recording():
		var time = recorder.get_current_record_time()
		ui.update_recording_timer(time)


func _on_interaction(_kargs):
	if mode == modes.PLAY:
		_set_mode(modes.RECORD_AND_PLAY)
	elif mode == modes.RECORD_AND_PLAY:
		_set_mode(modes.STOP)
	elif mode == modes.STOP:
		_set_mode(modes.PLAY)
	_execute_mode()
# ---------------------------------------------------------------------------- #
