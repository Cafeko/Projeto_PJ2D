extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Pegamos o nó do Laser (pai do Area2D)
	var laser = get_parent()
	
	# Verifica se o laser está ligado
	if laser.state == laser.states.INACTIVE:
		if body.name == "player":
			#print("Player tocou no laser → MORREU (via laser_collider)")
			body.die_and_respawn()
