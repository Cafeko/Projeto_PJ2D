extends CharacterBody2D

class_name Player

# --- Vars ------------------------------------------------------------------- #
@export var state_machine : StateMachine
@export var anim : AnimatedSprite2D
@export var graber : Graber

const SPEED = 70.0
const JUMP_VELOCITY = -350.0

enum direcion {LEFT, RIGHT}

var look_direction = direcion.RIGHT
var respawn_position: Vector2 = Vector2.ZERO
var can_start_recording : bool = false
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready() -> void:
	state_machine.init()
	respawn_position = global_position


func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
	if state_machine.get_current_state() == "Dead":
		return
	
	flit_to_look_side()
	
	gravity(delta)
	
	interactions_and_grab()

	move_and_slide()
	# Chama a nova função de detecção de esmagamento após o move_and_slide()
	check_for_squish()
# ---------------------------------------------------------------------------- #
# --- Nova Função ------------------------------------------------------------ #
# Verifica se o player está sendo esmagado.
func check_for_squish():
	# Só checamos se não estamos mortos ou pulando (por simplicidade inicial)
	if state_machine.get_current_state() == "Dead":
		return
		
	# A detecção de esmagamento pode ser complexa e depende do jogo.
	# Uma forma simples é verificar se há colisões ativas e fortes em direções opostas.
	
	# O CharacterBody2D é movido pelo move_and_slide().
	# Se ele tiver **mais de duas colisões** E **velocidade muito baixa** # (sugere que ele não está mais se movendo por estar preso/esmagado),
	# ou colisões em direções críticas (topo e base, ou lados opostos) 
	# com pouca ou nenhuma velocidade, é um forte indicativo de esmagamento.
	
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

# --- Internal Funcs --------------------------------------------------------- #
# Ajusta player de acordo com direção que está olhando.
func flit_to_look_side():
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
		if graber.is_holding() or graber.has_grabable():
			graber.grab_and_drop()
		elif can_start_recording:
			global.start_recording.emit(self)
			global.play_recording.emit()
	if Input.is_action_just_pressed("use") and graber.is_holding():
		var item = graber.get_held_grabable().get_object()
		if is_instance_of(item, Item) and item.is_usable():
			item.use_item()
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


# Faz player ir para o estado morto.
func die_and_respawn():
	state_machine.go_to_state.emit("Dead")


# Atualiza a posição que vai respawnar.
func update_checkpoint(new_position: Vector2):
	if new_position != respawn_position:
		print("Checkpoint salvo!")
		respawn_position = new_position


# Retorna o estado atual do player para a recording_tape gravar as ações dele.
func get_record_data():
	return {"position" : self.global_position, "animation" : anim.animation,
			"flip_h": anim.flip_h}
# ---------------------------------------------------------------------------- #
