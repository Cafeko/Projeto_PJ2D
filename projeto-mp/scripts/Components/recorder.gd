extends Node
class_name Recorder

# --- Signals ---------------------------------------------------------------- #
signal recording_canceled
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@onready var player_copy = preload("res://entities/player_copy.tscn")
var timer : Timer
var player : Player
var max_record_tapes : int
var max_record_tapes_time : float
var time_per_frame : float = 0.01
var can_start_recording : bool = false
var can_start_playing : bool = false
var is_recording : bool = false
var is_playing_recording : bool = false
var recording_tapes = []
var player_copy_list = []
var current_recording_tape : RecordingTape 
# ---------------------------------------------------------------------------- #
# --- Init, Ready and Physics Process ---------------------------------------- #
func _init(p:Player, n_record_tapes:int, record_time:float):
	player = p
	max_record_tapes = n_record_tapes
	max_record_tapes_time = record_time


func _ready():
	_setup_timer()


func _physics_process(_delta: float):
	# Verifica se pode começar a gravar ou executar as gravações.
	if player.is_moving():
		if can_start_recording:
			start_recording()
		if can_start_playing:
			play_recording()
	
	#if len(recording_tapes) > 0:
		#var rt = recording_tapes[-1]
		#print(rt.recording_data[-1], rt.current_recording_time)
# ---------------------------------------------------------------------------- #
# --- Record ----------------------------------------------------------------- #
# Inicia o processo de começar a gravar as ações do player;
# Executada quando player interagi com checkpoint.
func prepare_to_record():
	# Se iniciou gravação com uma gravação já acontecendo.
	if len(recording_tapes) > 0 and not recording_tapes[-1].finalized:
		# Cancela gravação que está sendo feita.
		cancel_recording()
		return
	# Indica que pode começar a gravar.
	can_start_recording = true
	is_recording = false


# Inicia gravação.
func start_recording():
	can_start_recording = false
	is_recording = true
	# Cria uma nova recording tape.
	var new_recording_tape = _create_new_recording_tape()
	# Add nova recording tape como atual.
	current_recording_tape = new_recording_tape
	# Add first recording frame.
	new_recording_tape.add_recording_frame(0.0)
	timer.start()


# Continua gravando as ações do player.
func _record():
	if current_recording_tape:
		current_recording_tape.add_recording_frame(timer.wait_time)
		timer.start()


func get_is_recording():
	return is_recording


# Finaliza gravação de ações.
func finalize_recording():
	_record()
	can_start_recording = false
	is_recording = false
	if current_recording_tape:
		current_recording_tape.finalize()
		recording_tapes.append(current_recording_tape)
		if len(recording_tapes) > max_record_tapes:
			recording_tapes.pop_front()
		current_recording_tape = null


# Cancela a gravação atual.
func cancel_recording():
	can_start_recording = false
	is_recording = false
	current_recording_tape = null
	recording_canceled.emit()


# Para a gravação.
func stop_recording():
	can_start_recording = false
	is_recording = false
	current_recording_tape = null
# ---------------------------------------------------------------------------- #
# --- Play ------------------------------------------------------------------- #
# Inicia o processo de executar gravações.
func prepare_to_play():
	# Limpa lista de copias.
	_clear_player_copy_list()
	# Prepara para começar a executar gravações, se tiver gravações.
	if len(recording_tapes) > 0:
		can_start_playing = true
		is_playing_recording = false


# Inicia execução de gravações.
func play_recording():
	can_start_playing = false
	is_playing_recording = true
	# Percorre lista de recording tapes:
	for i in range(len(recording_tapes)):
		# Não cria copia para a primeira gravação caso ela possa ser substituida.
		if i == 0 and _vai_substituir_ultima():
			player_copy_list.append(null)
		# Se gravação foi finalizada:
		elif recording_tapes[i].finalized:
			# Vai para o inicio da gravação.
			recording_tapes[i].restart_current_frame()
			# Obtem dados do frame inicial da gravação e passa para o proximo.
			var data = recording_tapes[i].get_and_play_frame_data()
			var copy = _create_new_player_copy()
			# Adiciona copia na lista de copias.
			player_copy_list.append(copy)
			# Prepara copia inicialmete.
			_setup_copy_inicial(copy, data)
		# Se gravação não está finalizada (ainda esta gravando):
		else:
			# Não cria copia para essa gravação.
			player_copy_list.append(null)
	timer.start()


# Continua executando gravações.
func _play():
	# Para de executar gravações se todas tiverem acabados.
	if not _has_recording_to_play():
		is_playing_recording = false
		return
	# Percorre lista de recording tapes:
	for i in range(len(recording_tapes)):
		var tape : RecordingTape = recording_tapes[i]
		# Pula tape se já tiver acabado.
		if tape.in_tape_end() or not tape.finalized:
			continue
		# Obtem dados do proximo frame.
		var next_data = tape.get_next_frame_data()
		if next_data == null:
			next_data = {}
		# Obtem dados do frame atual e avança para o proximo frame.
		var data = tape.get_and_play_frame_data()
		# Obtem copia respectiva a tape atual.
		var copy: PlayerCopy = player_copy_list[i]
		if copy != null and data != null:
			_copy_act(copy, data, next_data)
	timer.start()


func get_is_playing_recording():
	return is_playing_recording


# Finaliza execução de gravações.
func stop_playing():
	can_start_playing = false
	is_playing_recording = false
	_clear_player_copy_list()
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
# Cria e prepara o timer.
func _setup_timer():
	timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(time_per_frame)
	timer.timeout.connect(_on_timeout)


# Cria nova RecordingTape.
func _create_new_recording_tape():
	var new_recording_tape := RecordingTape.new(max_record_tapes_time, player)
	new_recording_tape.recording_timeout.connect(_recording_time_out)
	return new_recording_tape


# Remove e apaga a ultima recording tape
func _delete_last_tape():
	var tape: RecordingTape = recording_tapes.pop_back()
	if tape:
		tape.queue_free()


# Limpa a lista de copias de player.
func _clear_player_copy_list():
	for copy in player_copy_list:
		if copy:
			copy.queue_free()
	player_copy_list = []


# Criar nova copia do player.
func _create_new_player_copy():
	var copy = player_copy.instantiate()
	self.add_child(copy)
	return copy


# Prepara copia inicialmente para executar ações gravadas. 
func _setup_copy_inicial(copy: PlayerCopy, data:Dictionary):
	copy.global_position = data["position"]
	copy.current_anim = data["animation"]


# Faz copia agir de acordo com os dados recebidos.
func _copy_act(copy: PlayerCopy, current_data:Dictionary, _next_data:Dictionary):
	# Move copia.
	var tween = create_tween()
	tween.tween_property(copy, "global_position", current_data["position"], timer.wait_time)
	# Muda animação da copia.
	copy.current_anim = current_data["animation"]
	# Muda direção que a copia está olhando.
	copy.anim.flip_h = current_data["flip_h"]


# Verifica se tem recording tapes validas para serem executadas.
func _has_recording_to_play():
	for tape in recording_tapes:
		if not tape.in_tape_end() and tape.finalized:
			return true
	return false


# Indica se a gravação mais antiga vai ser substituida.
func _vai_substituir_ultima():
	return is_recording and len(recording_tapes) + 1 > max_record_tapes
# ---------------------------------------------------------------------------- #
# --- On Signal -------------------------------------------------------------- #
# Cancela gravação pois tempo de gravação acabou e player não morreu.
func _recording_time_out():
	cancel_recording()


# Finaliza a gravação (player morreu a tempo).
func _on_player_died():
	stop_playing()
	finalize_recording()


# Fica executando, gravando e tocando as ações do player conforme o tempo passa.
func _on_timeout():
	if is_recording:
		_record()
	if is_playing_recording:
		_play()
# ---------------------------------------------------------------------------- #
