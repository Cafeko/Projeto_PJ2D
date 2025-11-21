extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	sprite.play("default")

func _on_body_entered(body):
	print("Body entrou:", body)

	# Verifica se o body é o Player OU se o pai dele é o Player
	var root = body
	while root:
		if root is Player:
			print("colidiu com o player!")
			sprite.play("pressionado")
			return
		root = root.get_parent()
