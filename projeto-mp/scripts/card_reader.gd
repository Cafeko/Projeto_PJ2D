# scripts/CardReader.gd
extends Area2D
class_name CardReader

@export var anim: AnimatedSprite2D

# --- Ready ---
func _ready():
	# Conecta o sinal 'body_entered' a uma função interna para detecção de colisão.
	# O Keycard é um RigidBody2D, que é um tipo de 'Body' em um Area2D.
	body_entered.connect(_on_body_entered)
	
	# Inicia com a animação "locked" (assumindo que seja o frame inicial)
	if anim:
		anim.play("locked")

# --- Detecção de Colisão ---
# Esta função é chamada quando um Corpo (Body) entra nesta Area2D.
func _on_body_entered(body: Node2D):
	# Tenta converter o 'body' para o tipo 'Keycard'.
	# A classe 'Keycard' foi exportada no script keycard.gd (class_name Keycard).
	if body is Keycard:
		var keycard_instance: Keycard = body
		
		# Mudar a animação do CardReader para "unlocked"
		if anim and anim.animation != "unlocked":
			anim.play("unlocked")
			print("Keycard detectado e CardReader desbloqueado!")
			
			# FAZ O CARTÃO SUMIR AQUI!
			keycard_instance.queue_free()

		# Por enquanto, vamos apenas garantir que o Keycard chame sua própria lógica de uso.
		keycard_instance.use_item()
