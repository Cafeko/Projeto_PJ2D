extends Node2D

@export var shape: Shape2D
@export var color: Color = Color(1, 0, 0, 0.4)  # vermelho transparente

func _draw():
	if shape == null:
		return

	if shape is RectangleShape2D:
		draw_rect(Rect2(-shape.extents, shape.extents * 2), color)

	elif shape is CircleShape2D:
		draw_circle(Vector2.ZERO, shape.radius, color)

	queue_redraw() # Godot 4: redesenha continuamente
