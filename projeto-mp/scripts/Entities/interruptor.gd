extends Activator
class_name Interruptor

# --- Configurações --- #
#@export_group("Configurações do Interruptor")
@export var duration: float = 10.0 # Tempo em segundos
@export var interactable : Interactable
@export var timer_box : InfoBox

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
	
	interactable.interaction.connect(_on_interaction)
	
	# Garante o estado visual inicial (desligado)
	update_visuals()


func _physics_process(_delta: float):
	if not timer.is_stopped():
		var time_string = "%.2f" %timer.time_left
		timer_box.update_text(time_string)


# --- Lógica Principal --- #
func trigger_switch():
	# Ativa a lógica base (classe Activator)
	activate()
	
	interactable.set_can_interact_with(false)
	
	# Inicia ou Reinicia a contagem dos 10 segundos
	timer.start(duration)
	
	# Atualiza a animação Exibe caixa com tempo.
	update_visuals()


func _on_timer_timeout():
	# Ocorre quando o Timer chega a 0
	deactivate()
	# Desativa a lógica base
	interactable.set_can_interact_with(true)
	# Atualiza sprite e esconde caixa com tempo.
	update_visuals()


func update_visuals():
	# Verifica o estado herdado da classe pai (Activator)
	if is_active():
		anim.play("interruptor_on")
		timer_box.set_visibility(true)
	else:
		anim.play("interruptor_off")
		timer_box.set_visibility(false)


func _on_interaction(_kargs:Dictionary):
	trigger_switch()
