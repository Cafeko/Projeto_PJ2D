extends CharacterBody2D

class_name Player

# --- Vars ------------------------------------------------------------------- #
@export var state_machine : StateMachine
@export var anim : AnimatedSprite2D

@onready var holding_spot: Node2D = $HoldingSpot
@onready var box_cast: ShapeCast2D = $BoxCast

const SPEED = 50.0
const JUMP_VELOCITY = -350.0

var grabbable_object = null
var held_object = null

var is_box_colliding: bool = false

# Posição para onde o jogador voltará ao morrer
var respawn_position: Vector2 = Vector2.ZERO

var can_start_recording : bool = false
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready() -> void:
	state_machine.init()
	
	## NOVO: Conectar os sinais da nossa Area2D
	## Certifique-se de que o nome "PickupArea" bate com o nó que você criou
	$PickupArea.body_entered.connect(_on_pickup_area_body_entered)
	$PickupArea.body_exited.connect(_on_pickup_area_body_exited)
	# --- ADICIONE ESTA LINHA ---
	# Diz ao sensor para também ignorar a sua própria área de pickup
	box_cast.add_exception($PickupArea)
	# ---------------------------
	# --- ADICIONE ESTA LINHA ---
	# Ignora a colisão principal do próprio jogador
	box_cast.add_exception(self)
	# ---------------------------
	# --- ADICIONE ESTA LINHA NO FINAL DA FUNÇÃO _ready() ---
	# Define a posição inicial como o primeiro ponto de respawn
	respawn_position = global_position
	
	# --- ADICIONE ESTA LINHA ---
	# Conecta o sinal "timeout" do Timer a uma nova função
	#$RespawnTimer.timeout.connect(_on_respawn_timer_timeout)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	# --- ADICIONE ESTAS DUAS LINHAS ---
	# Se o jogador estiver morto, não execute NENHUMA ação e física.
	if state_machine.get_current_state() == "Dead":
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	## NOVO: Lógica de Interação (Pegar/Largar)
	## Verificamos isso antes dos estados, pois queremos pegar/largar em qualquer estado (exceto pulando)
	if Input.is_action_just_pressed("interact") and state_machine.get_current_state() != "Jump":
		if held_object:
			# Se estamos segurando algo, largue.
			drop_object()
		elif grabbable_object:
			# Se não estamos segurando, mas podemos pegar algo, pegue.
			grab_object(grabbable_object)
		elif can_start_recording:
			global.start_recording.emit(self)
			global.play_recording.emit()
	
		# -------- MUDANÇA AQUI --------
	# Chamamos a nova função antes de mover
	update_held_object_position()
	# ------------------------------

	move_and_slide()
# ---------------------------------------------------------------------------- #
# ---  ----------------------------------------------------------------------- #
#func go_to_walk_state():
	#status = PlayerState.walk
	#anim.play("walk")
	#
#func go_to_jump_state():
	#status = PlayerState.jump
	#anim.play("jump")
	#velocity.y = JUMP_VELOCITY
	
#func idle_state():
	#move()
	#if velocity.x != 0:
		#go_to_walk_state()
		#return
	#
	#if Input.is_action_just_pressed("jump"):
		#go_to_jump_state()
		#return
	#
#func walk_state():
	#move()
	#if velocity.x == 0:
		#go_to_idle_state()
		#return		
	#
	#if Input.is_action_just_pressed("jump"):
		#go_to_jump_state()
		#return		

#func jump_state():
	#move()
	#if is_on_floor():
		#if velocity.x == 0:
			#go_to_idle_state()
		#else:
			#go_to_walk_state()
		#return

func move():
	var direction := Input.get_axis("left", "right")
	
	# --- LÓGICA DE PARADA ADICIONADA ---
	if is_box_colliding:
		# Descobre para onde estamos virados (1.0 = direita, -1.0 = esquerda)
		var facing_dir = 1.0
		if anim.flip_h:
			facing_dir = -1.0
		
		# Se a direção que queremos ir (direction)
		# é a mesma para onde estamos virados (facing_dir)...
		if direction == facing_dir:
			direction = 0.0 # Force o jogador a parar
	# --- FIM DA LÓGICA ---
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction < 0:
		anim.flip_h = true	
		## NOVO: Vira o local de segurar a caixa junto com o sprite
		#holding_spot.position.x = -16.0
		# LINHA DE DEBUG:
		#print("Virando ESQUERDA, scale agora e: ", holding_spot.scale.x)
	elif direction > 0:
		anim.flip_h = false	
		## NOVO: Desvira o local de segurar a caixa
		#holding_spot.position.x = 16.0
		# LINHA DE DEBUG:
		#print("Virando DIREITA, scale agora e: ", holding_spot.scale.x)

## -------------------------------------------------
## ## NOVO: Funções para Pegar e Largar Objetos ##
## -------------------------------------------------

func _on_pickup_area_body_entered(body):
	# Chamado quando um corpo físico entra na nossa área
	if body.is_in_group("grabbable") and not held_object:
		grabbable_object = body

func _on_pickup_area_body_exited(body):
	# Chamado quando um corpo físico sai da nossa área
	if body == grabbable_object:
		grabbable_object = null

func grab_object(body):
	# Estamos segurando este objeto
	held_object = body
	# Não podemos mais pegar outros
	grabbable_object = null 
	
	# --- ADICIONE ESTA LINHA ---
	# Diz ao sensor para ignorar este corpo específico (a caixa)
	box_cast.add_exception(body)
	# ---------------------------
	
	# 1. Remove o objeto da cena principal
	body.get_parent().remove_child(body)
	# 2. Adiciona o objeto como filho do "HoldingSpot"
	holding_spot.add_child(body)
	# 3. Reseta sua posição relativa ao "HoldingSpot"
	body.position = Vector2.ZERO
	# 4. Desativa sua forma de colisão para que ele não colida com o jogador
	body.get_node("CollisionShape2D").disabled = true
	
	# 5. ## CORREÇÃO AQUI ##
	#    Congela o corpo para ele parar de ser afetado pela física
	body.freeze = true 
	# A linha antiga era: body.mode = RigidBody2D.MODE_STATIC

func drop_object():
	if not held_object:
		return

	var body = held_object
	
	# --- ADICIONE ESTA LINHA ---
	# Diz ao sensor para parar de ignorar este corpo
	box_cast.remove_exception(body)
	# (Alternativamente, você pode usar box_cast.clear_exceptions())
	# ---------------------------
	
	# 1. Pega a posição global atual da caixa
	var world_pos = body.global_position
	
	# 2. Remove a caixa do "HoldingSpot"
	holding_spot.remove_child(body)
	# 3. Adiciona a caixa de volta à cena principal
	get_parent().add_child(body)
	# 4. Define sua posição global para onde estava
	body.global_position = world_pos
	
	# 5. Reativa a forma de colisão
	body.get_node("CollisionShape2D").disabled = false
	
	# 6. ## CORREÇÃO AQUI ##
	#    Descongela o corpo para ele voltar a ser afetado pela física
	body.freeze = false
	# A linha antiga era: body.mode = RigidBody2D.MODE_RIGID
	
	# Não estamos mais segurando nada
	held_object = null

## NOVO: Função para atualizar a posição da caixa e checar paredes
func update_held_object_position():
	# Resetamos a flag no início de cada frame
	is_box_colliding = false
	
	if not held_object:
		# ... (seu código existente para resetar a posição)
		var facing_dir = 1.0
		if anim.flip_h:
			facing_dir = -1.0
		holding_spot.position = Vector2(16.0 * facing_dir, -2.0)
		return
		
	# 1. Descobrir para onde o jogador está virado
	var facing_direction = 1.0
	if anim.flip_h: # Usa o sprite 'anim' como referência
		facing_direction = -1.0
	
	# 2. Definir a posição *desejada* da caixa
	#    (Usando os valores da sua imagem: x=16, y=-8)
	var desired_pos = Vector2(16.0 * facing_direction, -2.0)

	# 3. Configurar o Shapecast
	box_cast.target_position = desired_pos
	box_cast.force_shapecast_update() # Força a verificação agora
	
	# 4. Mover o HoldingSpot para a posição segura
	if box_cast.is_colliding():
		# --- ADICIONE ESTA LINHA ---
		is_box_colliding = true # AVISA O SCRIPT QUE BATEMOS!
		
		# ---- ADICIONE ESTA LINHA DE DEBUG ----
		print("BoxCast colidiu com: ", box_cast.get_collider(0).name)
		# -------------------------------------
		
		# Se colidir, puxe a caixa para perto
		var fraction = box_cast.get_closest_collision_safe_fraction()
		# Multiplica a posição desejada pela fração segura
		# (fraction * 0.95) dá uma pequena folga para não encostar
		holding_spot.position = desired_pos.lerp(Vector2.ZERO, 1.0 - (fraction * 0.95))
	else:
		# Se não colidir, vá para a posição normal
		holding_spot.position = desired_pos
		
# Esta função será chamada PELO ESPINHO
func die_and_respawn():
	state_machine.go_to_state.emit("Dead")
## Se já estivermos mortos, não faça nada (evita morrer 2x)
	#if status == PlayerState.dead:
		#return
#
	#print("Morri! Iniciando timer de respawn...")
	#
	## 1. Define o estado para DEAD (isso congela o jogador, como vimos no physics_process)
	#status = PlayerState.dead
	#
	## 2. Toca a sua animação de morte
	#anim.play("die") # (Certifique-se de que você tem uma animação chamada "die" no seu AnimatedSprite2D)
	#
	## 3. Reseta a velocidade
	#velocity = Vector2.ZERO
	#
	## 4. Larga a caixa se estiver segurando
	#if held_object:
		#drop_object()
		#
	#global.finalize_recording.emit()
	## 5. Inicia o timer de 1 segundo
	#$RespawnTimer.start()

# Esta função é chamada AUTOMATICAMENTE pelo RespawnTimer após 1 segundo
#func _on_respawn_timer_timeout():
	#print("Revivendo no checkpoint!")
	#
	## 1. Move o jogador de volta para a posição salva
	#global_position = respawn_position
	#
	## 2. Traz o jogador de volta à vida
	#go_to_idle_state() # Isso define o status de volta para IDLE e toca a animação "idle"
	
# Esta função será chamada PELO CHECKPOINT
func update_checkpoint(new_position: Vector2):
	# Se a nova posição for diferente da atual, atualiza
	if new_position != respawn_position:
		print("Checkpoint salvo!")
		respawn_position = new_position
# --- Recording -------------------------------------------------------------- #
func get_record_data():
	return {"position" : self.global_position, "animation" : anim.animation,
			"flip_h": anim.flip_h}
# ---------------------------------------------------------------------------- #
