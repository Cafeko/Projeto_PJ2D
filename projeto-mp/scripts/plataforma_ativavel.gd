extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision := $CollisionShape2D

var ativa := false

func toggle():
	ativa = !ativa
	atualizar_estado()

func atualizar_estado():
	if ativa:
		sprite.play("ativada")

		# Liga colisão
		self.set_collision_layer_value(3, true)
		self.set_collision_mask_value(1, true)   # Player layer

	else:
		sprite.play("default")

		# Desliga colisão
		self.set_collision_layer_value(3, false)
		self.set_collision_mask_value(1, false)
