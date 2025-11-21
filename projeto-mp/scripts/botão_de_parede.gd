extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var plataforma_ativavel: StaticBody2D = $"../PlataformaAtivavel"

var foi_ativado: bool = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	sprite.play("default")
	print("Ponte encontrada?", plataforma_ativavel)

func _on_body_entered(body):
	if foi_ativado:
		return  # já ativou antes, ignora

	var root = body
	while root:
		if root is Player:
			foi_ativado = true   # impede novas ativações
			print("colidiu com o player!")
			sprite.play("pressionado")

			plataforma_ativavel.toggle()
			return

		root = root.get_parent()
