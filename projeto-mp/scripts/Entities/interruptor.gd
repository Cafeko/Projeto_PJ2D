extends Activator
class_name Interruptor

# --- Configurações --- #
#@export_group("Configurações do Interruptor")
@export var duration: float = 10.0 # Tempo em segundos

# --- Referências aos Nós --- #
# O Timer é um nó padrão do Godot chamado "Timer"
@onready var timer: Timer = $Timer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Variável interna para saber se o jogador está na área
var player_in_range: bool = false

# --- Ready --- #
func _ready():
	# Configuração do Timer via código para garantir
	#timer.wait_time = duration
	timer.one_shot = true # Importante: só roda uma vez quando acionado
	
	# Conecta o sinal de quando o tempo acaba
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	
	# Garante o estado visual inicial (desligado)
	update_visuals()

# --- Input --- #
func _unhandled_input(event):
	# Se o player estiver na Area2D e apertar "E" (ação "interact")
	if player_in_range and event.is_action_pressed("interact"):
		trigger_switch()

# --- Lógica Principal --- #
func trigger_switch():
	# Ativa a lógica base (classe Activator)
	activate()
	
	# Inicia ou Reinicia a contagem dos 10 segundos
	timer.start(duration)
	
	# Atualiza a animação
	update_visuals()
	#print("Interruptor ligado por ", duration, " segundos.")

func _on_timer_timeout():
	# Ocorre quando o Timer chega a 0
	deactivate() # Desativa a lógica base
	update_visuals()
	#print("Tempo acabou. Interruptor desligado.")

func update_visuals():
	# Verifica o estado herdado da classe pai (Activator)
	if is_active():
		anim.play("interruptor_on")
	else:
		anim.play("interruptor_off")

# --- Sinais da Node2D --- #
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		player_in_range = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("Algo entrou na área: ", body.name) # Adicione isso para testar
	if body.name == "player" or body.is_in_group("player"):
		player_in_range = true
		#print("É o player! Pode apertar E.")
