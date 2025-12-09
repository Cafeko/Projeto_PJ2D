extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Pegamos o nó do Laser (pai do Area2D)
	var laser = get_parent()
	
	# Verifica se o laser está ligado
	if laser.state == laser.states.INACTIVE:
		if body.has_method("die"):
			body.die()


func _on_area_entered(area: Area2D):
	# Pegamos o nó do Laser (pai do Area2D)
	var laser = get_parent()
	
	# Verifica se o laser está ligado
	if laser.state == laser.states.INACTIVE:
		if area.get_parent().has_method("die"):
			area.get_parent().die()
