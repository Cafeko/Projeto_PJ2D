extends Area2D

# Conecte o sinal "body_entered" a esta função
func _on_body_entered(body):
	# Checa se o corpo que entrou tem a função "update_checkpoint"
	if body.has_method("update_checkpoint"):
		# Se for o Player, chama a função e passa a POSIÇÃO DESTE CHECKPOINT
		body.update_checkpoint(global_position)
	if "can_start_recording" in body:
		body.can_start_recording = true
		# Opcional: Desativa o checkpoint depois de tocado uma vez
		# $CollisionShape2D.disabled = true
		# (você também pode tocar uma animação, mudar a cor do sprite, etc.)


func _on_body_exited(body: Node2D) -> void:
	if "can_start_recording" in body:
		body.can_start_recording = false
		global.play_recording.emit()
