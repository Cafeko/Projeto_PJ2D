extends Node
class_name Recorder

# --- Signals ---------------------------------------------------------------- #
signal recording_timeout
signal recording_canceled
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@onready var player_copy = preload("res://entities/player_copy.tscn")
var frame_timer : Timer
var recording_timer : Timer
var player : Player
var max_record_tapes : int
var max_record_time : float
var current_record_time : float
var time_per_frame : float = 0.01
var can_start_recording : bool = false
var can_start_playing : bool = false
var is_recording : bool = false
var is_playing_recording : bool = false
var recording_tapes = []
var player_copy_list = []
var current_recording_tape : RecordingTape
var error_tolerance = {"floating": 3, "dead": 3, "grab": 3}
var current_error_tolerance = {}
# ---------------------------------------------------------------------------- #
# --- Init, Ready and Physics Process ---------------------------------------- #
func _init(p:Player, n_record_tapes:int, record_time:float):
	player = p
	max_record_tapes = n_record_tapes
	max_record_time = record_time
	_setup_timer()


func _ready():
	recording_timeout.connect(_on_recording_time_out)


func _physics_process(_delta: float):
	# Verifica se pode começar a gravar ou executar as gravações.
	if player.is_moving():
		if can_start_recording:
			start_recording()
		if can_start_playing:
			play_recording()
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
	# Prepara tempo de gravação:
	current_record_time = max_record_time
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
	new_recording_tape.add_recording_frame()
	frame_timer.start()


# Continua gravando as ações do player.
func _record():
	if current_recording_tape:
		current_recording_tape.add_recording_frame()


func get_is_recording():
	return is_recording


# Finaliza gravação de ações.
func finalize_recording():
	_count_time()
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
	# Prepara tempo de gravação:
	current_record_time = max_record_time
	# Reinicia tolerancias:
	current_error_tolerance = error_tolerance.duplicate()
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
	frame_timer.start()


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
			# Faz copia agir.
			var execution_ok = _copy_act(copy, data, next_data)
			# Se a execução das ações tiver detectado algum problema:
			if not execution_ok:
				# Deleta copia.
				player_copy_list[i] = null
				copy.queue_free()


func get_is_playing_recording():
	return is_playing_recording


# Finaliza execução de gravações.
func stop_playing():
	can_start_playing = false
	is_playing_recording = false
	_clear_player_copy_list()
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
# Retorna o tempo de gravação atual.
func get_current_record_time():
	return current_record_time


# Finaliza a gravação (player morreu a tempo).
func player_died():
	stop_playing()
	finalize_recording()
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
# Cria e prepara o timer.
func _setup_timer():
	# Frame timer:
	frame_timer = Timer.new()
	add_child(frame_timer)
	frame_timer.one_shot = true
	frame_timer.set_wait_time(time_per_frame)
	frame_timer.timeout.connect(_on_timeout)


# Cria nova RecordingTape.
func _create_new_recording_tape():
	return RecordingTape.new(player)


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
func _copy_act(copy: PlayerCopy, current_data:Dictionary, next_data:Dictionary):
	# Copia executando ações:
	# Move copia.
	var tween = create_tween()
	tween.tween_property(copy, "global_position", current_data["position"], frame_timer.wait_time)
	# Muda animação da copia.
	copy.play_animation(current_data["animation"])
	# Muda direção que a copia está olhando.
	copy.flip(current_data["flip_h"])
	# Agarra objetos:
	if len(next_data.keys()) > 0:
		if current_data["is_holding"] == false and next_data["is_holding"] == true:
			copy.grab()
		elif current_data["is_holding"] == true and next_data["is_holding"] == false:
			copy.drop()
	if current_data["interacted"] == true:
		copy.interact()
	# Detecta impedimentos:
	# Detecta se copia está colidindo.
	if copy.is_colliding():
		return false
	# Detecta se está flutuando.
	if current_data["on_floor"] == true and copy.is_in_floor() == false:
		current_error_tolerance["floating"] -= 1
		if current_error_tolerance["floating"] <= 0:
			return false
	else:
		current_error_tolerance["floating"] = error_tolerance["floating"]
	# Detecta que copia morreu.
	if copy.is_dead() != (current_data["state"] == "Dead"):
		current_error_tolerance["dead"] -= 1
		if current_error_tolerance["dead"] <= 0:
			return false
		else:
			current_error_tolerance["dead"] = error_tolerance["dead"]
	# Detecta se está agarrando quando não devia.
	if copy.is_grabing() != current_data["is_holding"]:
		current_error_tolerance["grab"] -= 1
		if current_error_tolerance["grab"] <= 0:
			return false
		else:
			current_error_tolerance["grab"] = error_tolerance["grab"]
	# Se chegou ao final nada impediu.
	return true


# Verifica se tem recording tapes validas para serem executadas.
func _has_recording_to_play():
	for i in range(len(recording_tapes)):
		var tape = recording_tapes[i]
		if not tape.in_tape_end() and tape.finalized and player_copy_list[i]:
			return true
	return false


# Indica se a gravação mais antiga vai ser substituida.
func _vai_substituir_ultima():
	return is_recording and len(recording_tapes) + 1 > max_record_tapes


# Desconta o tempo de cada frame do timer da gravação.
func _count_time():
	if current_record_time <= 0.0:
		recording_timeout.emit()
	else:
		current_record_time -= frame_timer.wait_time
# ---------------------------------------------------------------------------- #
# --- On Signal -------------------------------------------------------------- #
# Cancela gravação pois tempo de gravação acabou e player não morreu.
func _on_recording_time_out():
	cancel_recording()


# Fica executando, gravando e tocando as ações do player conforme o tempo passa.
func _on_timeout():
	if is_recording:
		_record()
	if is_playing_recording:
		_play()
	if is_recording or is_playing_recording:
		_count_time()
		frame_timer.start()
# ---------------------------------------------------------------------------- #
