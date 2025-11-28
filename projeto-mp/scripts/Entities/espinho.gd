extends Area2D

# Conecte o sinal "body_entered" a esta função
func _on_body_entered(body):
	if body.has_method("die"):
		body.die()


func _on_area_entered(area: Area2D):
	if area.get_parent().has_method("die"):
		area.get_parent().die()
