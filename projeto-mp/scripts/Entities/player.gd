extends CharacterBody2D
class_name Player

# --- Vars ------------------------------------------------------------------- #
@export var state_machine : StateMachine
@export var anim : AnimatedSprite2D
@export var graber : Graber
@export var interactor : Interactor

const SPEED = 70.0
const JUMP_VELOCITY = -350.0

enum direcion {LEFT, RIGHT}

var look_direction = direcion.RIGHT
var current_checkpoint : Checkpoint
var can_start_recording : bool = false
var safe_to_reset_current_fase : bool = false
var respawn_time : float = 0.1
var current_respawn_time : float
var can_act : bool = true
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready() -> void:
	state_machine.init()


func _physics_process(delta: float):
	state_machine.process_physics(delta)
	
	if state_machine.get_current_state() == "Dead":
		return
	
	fit_to_look_side()
	
	gravity(delta)
	
	if can_act:
		interactions_and_grab()
		move_and_slide()
	
	check_for_squish()
	
	make_safe_reset_current_fase(delta)
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
# Ajusta player de acordo com direção que está olhando.
func fit_to_look_side():
	if look_direction == direcion.LEFT:
		anim.flip_h = true
		graber.set_direction(-1)
	elif look_direction == direcion.RIGHT:
		anim.flip_h = false
		graber.set_direction(1)


# Aplica gravidade no player.
func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


# Executa interações e agarra objetos.
func interactions_and_grab():
	if Input.is_action_just_pressed("interact") and state_machine.get_current_state() != "Jump":
		if interactor.get_interactable_target():
			var kargs := {}
			interactor.do_interaction(kargs)
		elif graber.is_holding() or graber.has_grabable():
			graber.grab_and_drop()
	if Input.is_action_just_pressed("use") and graber.is_holding():
		var item = graber.get_held_grabable().get_object()
		if is_instance_of(item, Item) and item.is_usable():
			item.use_item()


# Verifica se o player está sendo esmagado.
func check_for_squish():
	# Só checamos se não estamos mortos ou pulando (por simplicidade inicial)
	if state_machine.get_current_state() == "Dead":
		return
	
	# 1. Colisão vertical: Pego entre chão e teto/plataforma acima
	# Note: is_on_ceiling() não é garantido para colisões ativas/movimento.
	# Vamos checar se is_on_floor() E tem colisões no topo.
	
	var is_squished_vertical = false
	var is_squished_horizontal = false
	
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			# Se há uma colisão onde a normal aponta para baixo (colisão no topo)
			if collision.get_normal().y > 0: 
				is_squished_vertical = true
				break
	
	# 2. Colisão horizontal: Pego entre paredes ou objetos laterais.
	var collision_left_count = 0
	var collision_right_count = 0
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		
		# Colisão no lado esquerdo (normal.x > 0)
		if normal.x > 0.5:
			collision_left_count += 1
		# Colisão no lado direito (normal.x < 0)
		elif normal.x < -0.5:
			collision_right_count += 1
			
	if collision_left_count > 0 and collision_right_count > 0:
		is_squished_horizontal = true

	# Se for esmagado (vertical ou horizontal), o player morre.
	if is_squished_vertical or is_squished_horizontal:
		print("Player Esmagado!")
		die_and_respawn()


# Emite sinal para resetar fase atual, depois de um delay.
func make_safe_reset_current_fase(delta):
	if safe_to_reset_current_fase:
		current_respawn_time -= delta
		if current_respawn_time <= 0:
			safe_to_reset_current_fase = false
			global.reset_current_fase.emit()
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
# Faz movimento do player.
func move():
	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction < 0:
		look_direction = direcion.LEFT
	elif direction > 0:
		look_direction = direcion.RIGHT


# Retorna se o player está movendo ou não.
func is_moving():
	return state_machine.get_current_state() == "Walk" or state_machine.get_current_state() == "Jump"


# Faz player ir para o estado morto.
func die_and_respawn():
	if not state_machine.get_current_state() == "Dead":
		state_machine.go_to_state.emit("Dead")


# Enable to reset current fase when is safe.
func safely_reset_current_fase():
	current_respawn_time = respawn_time
	safe_to_reset_current_fase = true


# Atualiza a posição que vai respawnar.
func update_checkpoint(new_checkpoint: Checkpoint):
	if new_checkpoint != current_checkpoint:
		if current_checkpoint != null:
			current_checkpoint.player_desativa_checkpoint()
		current_checkpoint = new_checkpoint


# Retorna posição de respawn que o player deve ir quando respawnar.
func get_respawn_position():
	if current_checkpoint:
		return current_checkpoint.global_position


func set_can_start_recording(valor:bool):
	can_start_recording = valor


func get_can_start_recording():
	return can_start_recording


func set_can_act(valor:bool):
	can_act = valor


# Retorna o estado atual do player para a recording_tape gravar as ações dele.
func get_record_data():
	return {"position" : self.global_position, "animation" : anim.animation,
			"flip_h": anim.flip_h}
# ---------------------------------------------------------------------------- #
