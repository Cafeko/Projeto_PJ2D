extends Area2D

class_name Graber

# --- Vars ------------------------------------------------------------------- #
@export var big_object_position : Marker2D
@export var small_object_position : Marker2D
@export var drop_object_position : Marker2D
@export var graber_object : CharacterBody2D
@export var collision_timer : Timer

enum positions {SMALL, BIG, DROP}

var direction : float = 1
var grabbable_object : Grabable
var held_object : Grabable
var update_position : bool = true
var temp_holder : Grabable = null
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float):
	_update_held_object_position()
	pass
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Função agarra ou solta objeto, dependendo se já tem ou não um objeto agarrado.
func grab_and_drop():
	if held_object:
		drop_object()
	elif grabbable_object:
		grab_object()


# Agarra objeto, se tiver um objeto para agarrar, e posiciona ele de acordo com 
# seu tamanho.
func grab_object():
	if not grabbable_object:
		return
	held_object = grabbable_object
	grabbable_object = null
	held_object.object.freeze = true
	held_object.object.add_collision_exception_with(graber_object)
	if held_object.is_small():
		set_held_object_position(positions.SMALL)
	else:
		set_held_object_position(positions.BIG)


# Solta objeto agarrado, se tiver, colocando ele na posição de drop.
func drop_object():
	if not held_object:
		return
	var target_position = drop_object_position.global_position
	target_position = get_drop_safe_position(target_position, held_object.get_size())
	if test_position_is_empty(held_object.get_grabable_shape(), target_position,
			held_object.get_object_collision_mask(), [held_object.get_object()]):
		#debug_show_shape(held_object.get_grabable_shape(), target_position)
		return
	set_held_object_position(positions.DROP)
	held_object.object.set_deferred("freeze", false)
	held_object.object.remove_collision_exception_with(graber_object)
	grabbable_object = held_object
	held_object = null


# Força o drop do objeto na posição que ele está.
func force_drop():
	if not held_object:
		return
	held_object.object.set_deferred("freeze", false)
	temp_holder = held_object
	grabbable_object = held_object
	held_object = null
	_timed_force_drop()

func _timed_force_drop():
	update_position = false
	collision_timer.start()


# Atualiza posição do objeto agarrado de acordo com seu tamanho.
func _update_held_object_position():
	if not update_position:
		return
	if not held_object:
		return
	if held_object.is_small():
		set_held_object_position(positions.SMALL)
	else:
		set_held_object_position(positions.BIG)


# Detecta se forma de colisão pode ficar na posição indicada sem colidir com algo.
func test_position_is_empty(collision_shape: CollisionShape2D,
							test_position:Vector2, mask_value := 1, ignore:Array=[]):
	var shape = collision_shape.shape
	var params := PhysicsShapeQueryParameters2D.new()
	
	params.shape_rid = shape.get_rid()
	params.collision_mask = mask_value
	params.transform = Transform2D(collision_shape.global_transform.get_rotation(),
								   test_position)
	
	var space = collision_shape.get_world_2d().direct_space_state
	var hits = space.intersect_shape(params)
	
	var valid = []
	for h in hits:
		if h.collider not in ignore:
			valid.append(h)
	return valid.size() > 0


# Mostra o shape na posição indicada.
func debug_show_shape(cshape: CollisionShape2D, pos: Vector2, duration := 0.5):
	var debug_node = load("res://Components/debug.tscn").instantiate()
	debug_node.shape = cshape.shape.duplicate()
	debug_node.global_position = pos
	get_tree().current_scene.add_child(debug_node)

	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func(): debug_node.queue_free())


# Retorna se tem um objeto sendo agarrado ou não.
func is_holding():
	return held_object != null

# Retorna se tem umn grabable na area do graber.
func has_grabable():
	return grabbable_object != null

# Retorna o grabable que está sendo segurado.
func get_held_grabable():
	return held_object
# ---------------------------------------------------------------------------- #
# --- Set Object Positions --------------------------------------------------- #
# Função responsavel por posicionar o objeto segurado de acordo com as
# 3 posições possiveis.
func set_held_object_position(p):
	if not held_object:
		return
	var target_position : Vector2
	var object_size = held_object.get_size()
	if p == positions.SMALL:
		target_position = small_object_position.global_position
		target_position = get_safe_position_small(target_position, object_size.y)
	elif p == positions.BIG:
		target_position = big_object_position.global_position
		target_position = get_safe_position_big(target_position, object_size.x)
	elif p == positions.DROP:
		target_position = drop_object_position.global_position
		target_position = get_drop_safe_position(target_position, object_size)
	held_object.set_object_position(target_position)


# Retorna uma posição segura para objetos segurados que não são pequenos.
func get_safe_position_big(target_position:Vector2, object_size_y):
	var safe_position = Vector2.ZERO
	safe_position = target_position - Vector2(0, object_size_y/2)
	return safe_position


# Retorna uma posição segura para objetos segurados que são pequenos.
func get_safe_position_small(target_position:Vector2, object_size_x):
	var safe_position = Vector2.ZERO
	safe_position = target_position + Vector2(object_size_x/2, 0) * direction
	return safe_position


# Retorna uma posição segura para objetos quando dropado.
func get_drop_safe_position(target_position:Vector2, object_size):
	var safe_position = Vector2.ZERO
	safe_position = target_position + Vector2(direction*(object_size.x/2), -(object_size.y/2))
	return safe_position


# Muda a direção do graber.
func set_direction(new_direction:float):
	direction = new_direction
	scale.x = new_direction
# ---------------------------------------------------------------------------- #
# --- Signal funcs ----------------------------------------------------------- #
# Detecta objetos que podem ser agarados que entram na area.
func _on_area_entered(area):
	if is_instance_of(area, Grabable):
		grabbable_object = area


# Retira objetos que podem ser agarados quando ele sair da area.
func _on_area_exited(area):
	if area == grabbable_object:
		grabbable_object = null

func _on_collision_timer_timeout() -> void:
	if temp_holder:
		temp_holder.object.remove_collision_exception_with(graber_object)
		temp_holder = null
	update_position = true
# ---------------------------------------------------------------------------- #
