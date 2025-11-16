extends StaticBody2D

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var caixa_node: Node = $"../caixa"

var pressionadores: Array = []

func _ready() -> void:
	if area:
		area.connect("body_entered", Callable(self, "_on_area_body_entered"))
		area.connect("body_exited", Callable(self, "_on_area_body_exited"))
	else:
		push_error("Area2D não encontrada como filho.")

	sprite.play("default")

	if caixa_node and not caixa_node.is_in_group("pressers"):
		caixa_node.add_to_group("pressers")

func _is_valid_presser(body: Node) -> bool:
	if body.is_in_group("pressers"):
		return true
	if body is CharacterBody2D or body is RigidBody2D:
		return true
	return false

func _on_area_body_entered(body: Node) -> void:
	if not _is_valid_presser(body):
		return
	if body.global_position.y > global_position.y + 8:
		return
	if not pressionadores.has(body):
		pressionadores.append(body)
	_update_visual_estado()

func _on_area_body_exited(body: Node) -> void:
	if not _is_valid_presser(body):
		return
	if pressionadores.has(body):
		pressionadores.erase(body)
	_update_visual_estado()

func _update_visual_estado() -> void:
	if pressionadores.is_empty():
		sprite.play("default")
	else:
		sprite.play("pressionado")
