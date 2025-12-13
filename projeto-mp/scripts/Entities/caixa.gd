extends Item

@onready var collision = $CollisionShape2D
@onready var dust_point = $DustPoint

var dust_particle_generator = preload("res://Visual/dust.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_object_body_entered)
	
func _on_object_body_entered(body: Node2D):
	# 1. Verifica se não é o Player que está colidindo.
	if is_instance_of(body, Player):
		if body_is_down(body):
			body.die()


func body_is_down(body:Node2D):
	if body.global_position.y > global_position.y + get_size().y/2: # Está em baixo
		if (body.global_position.x >= global_position.x - get_size().x/2 and
		body.global_position.x <= global_position.x + get_size().x/2):
			return true
	return false


func get_size():
	return collision.shape.size


func emit_collision_particle():
	var d1 = dust_particle_generator.instantiate()
	var d2 = dust_particle_generator.instantiate()
	get_tree().current_scene.add_child(d1)
	get_tree().current_scene.add_child(d2)
	d1.global_position = dust_point.global_position
	d2.global_position = dust_point.global_position
	d1.scale.x = 1
	d2.scale.x = -1
	d1.emitting = false
	d2.emitting = false
	d1.restart()
	d2.restart()
	d1.emitting = true
	d2.emitting = true
