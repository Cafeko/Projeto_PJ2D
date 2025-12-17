extends Area2D
class_name Checkpoint

# --- Var -------------------------------------------------------------------- #
@export var interactable : Interactable
@export var recording_tape_number : int = 1
@export var recording_time : float = 10.0
@export var frame_time : float = 0.01

@onready var anim = $AnimatedSprite2D
@onready var checkpoint_info_box : InfoBox = $Control/CheckpointBox
@onready var interaction_icon : InteractionIcon = $InteractionIcon 
@onready var checkpoint_sfx : AudioStreamPlayer = $Checkpoint_sfx
@onready var checkpoint_menu_sfx : AudioStreamPlayer = $Checkpoint_menu_sfx

enum modes {PLAY, RECORD_AND_PLAY, STOP, INTERACTING}

var recorder : Recorder
var ativado = false
var mode : modes = modes.STOP
var selected_modes_list = [modes.STOP, modes.RECORD_AND_PLAY, modes.PLAY]
var selected_mode_index : int = 1
var ui : CanvasLayer
var player : Player
var interacting_input_delay : float = 0.2
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready():
	set_ativado(false)
	global.player_died.connect(_on_player_died)
	ui = global.get_ui()
	checkpoint_info_box.set_visibility(false)

func _physics_process(delta: float):
	if mode == modes.INTERACTING and interacting_input_delay <= 0.0:
		_interacting()
	else:
		interacting_input_delay -= delta
	#_display_timer()
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
# Muda o estado de ativado do checkpoint.
func set_ativado(valor:bool):
	ativado = valor
	_update_anim()


# Executada para botar checkpoint como o checkpoint atual do player.
func player_ativa_checkpoint(p:Player):
	p.update_checkpoint(self)
	if not ativado:
		checkpoint_sfx.play()
		_create_recorder(p)
		set_ativado(true)


# Executa quando player troca o checkpoint atual.
func player_desativa_checkpoint():
	if ativado:
		set_ativado(false)
		_set_mode(modes.STOP)
		_execute_mode()


func set_recorder_time_speed(speed:float):
	if recorder:
		recorder.time_speed = speed
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
# Atuliza animação do checkpoint.
func _update_anim():
	if ativado:
		anim.play("default")
	else:
		anim.play("unraised_flag")


# Cria e prepara recorder.
func _create_recorder(p:Player):
	if recorder != null:
		recorder.queue_free()
	recorder = Recorder.new(p, recording_tape_number, recording_time, frame_time)
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
	elif  mode == modes.INTERACTING:
		print("Interacting")


# Executa de acordo com o modo atual.
func _execute_mode():
	if mode == modes.PLAY:
		recorder.stop_recording()
		recorder.stop_playing()
		recorder.prepare_to_play()
		ui.display_recording_timer()
		ui.display_play_texture()
		ui.update_recording_timer(recorder.get_current_record_time())
	elif mode == modes.RECORD_AND_PLAY:
		recorder.prepare_to_record()
		recorder.prepare_to_play()
		ui.display_recording_timer()
		ui.display_rec_texture()
		ui.update_recording_timer(recorder.get_current_record_time())
	elif mode == modes.STOP:
		recorder.stop_recording()
		recorder.stop_playing()
		ui.hide_recording_timer()


# Inicia processo de inteção com o checkpoint, impede que player possa agir.
func _start_interacting():
	interaction_icon.set_visibility(false)
	interacting_input_delay = 0.2
	player.set_can_act(false)
	checkpoint_menu_sfx.play()
	checkpoint_info_box.set_visibility(true)
	checkpoint_info_box.set_page_visible(selected_mode_index)
	checkpoint_info_box.update_infos(recorder.get_recording_tapes_list_len(),
				recorder.get_max_record_tapes(), recorder.get_max_record_time())
	_set_mode(modes.INTERACTING)


# Executado durante interação.
func _interacting():
	if Input.is_action_just_pressed("interact"):
		_end_interacting()
	if Input.is_action_just_pressed("left"):
		selected_mode_index -= 1
		if selected_mode_index < 0:
			selected_mode_index = 0
		else:
			checkpoint_menu_sfx.play()
	elif Input.is_action_just_pressed("right"):
		selected_mode_index += 1
		if selected_mode_index >= len(selected_modes_list):
			selected_mode_index = len(selected_modes_list) - 1
		else:
			checkpoint_menu_sfx.play()
	
	checkpoint_info_box.set_page_visible(selected_mode_index)


# Finaliza a interação permitindo que o player se mova e colocando o checkpoint
# no modo selecionado.
func _end_interacting():
	interaction_icon.set_visibility(true)
	_set_mode(selected_modes_list[selected_mode_index])
	_execute_mode()
	checkpoint_menu_sfx.play()
	checkpoint_info_box.set_visibility(false)
	player.set_can_act(true)
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
		var time = recorder.get_current_record_time()
		ui.update_recording_timer(time)


func _on_interaction(kargs:Dictionary):
	if (mode == modes.PLAY and recorder.get_is_playing_recording()) or mode == modes.RECORD_AND_PLAY:
		_set_mode(modes.STOP)
		_execute_mode()
	var player_interacting = kargs.get("player")
	if player_interacting:
		player = player_interacting
		_start_interacting()
# ---------------------------------------------------------------------------- #
