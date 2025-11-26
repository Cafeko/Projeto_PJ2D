extends Area2D
@onready var anim = $AnimatedSprite2D
var ativado = false # Variável para impedir que a animação reinicie se o player passar de novo

func _ready():
	# ISSO AQUI resolve o seu problema:
	# Assim que o jogo começar, ele força a animação de bandeira abaixada a tocar.
	anim.play("unraised_flag")

# Conecte o sinal "body_entered" a esta função
func _on_body_entered(body):
	# Checa se o corpo que entrou tem a função "update_checkpoint"
	if body.has_method("update_checkpoint"):
		# Se for o Player, chama a função e passa a POSIÇÃO DESTE CHECKPOINT
		body.update_checkpoint(global_position)
		# Se ainda não foi ativado, troca a animação
		if not ativado:
			anim.play("default") # Toca a animação da bandeira subindo
			ativado = true       # Marca como ativado para não tocar de novo
			
	if "can_start_recording" in body:
		body.can_start_recording = true
		# Opcional: Desativa o checkpoint depois de tocado uma vez
		# $CollisionShape2D.disabled = true
		# (você também pode tocar uma animação, mudar a cor do sprite, etc.)


func _on_body_exited(body: Node2D) -> void:
	if "can_start_recording" in body:
		body.can_start_recording = false
		global.play_recording.emit()
