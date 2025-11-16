extends Area2D

# Conecte o sinal "body_entered" a esta função
func _on_body_entered(body):
	# Checa se o corpo que entrou tem a função "die_and_respawn"
	if body.has_method("die_and_respawn"):
		# Se tiver (ou seja, se for o Player), chama a função nele
		body.die_and_respawn()
