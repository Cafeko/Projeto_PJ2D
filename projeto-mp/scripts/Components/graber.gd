extends Area2D

class_name Graber

# --- Vars ------------------------------------------------------------------- #
@export var big_object_position : Marker2D
@export var small_object_position : Marker2D
@export var drop_object_position : Marker2D
@export var graber_object : CharacterBody2D
@onready var drop_object_sfx = $DropObjectSFX as AudioStreamPlayer

enum positions {SMALL, BIG, DROP}

var direction : float = 1
var grabbable_object : Grabable
var held_object : Grabable
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
# No script Graber.gd

func drop_object():
	
	if not held_object:
		return
	
	# 1. CONEXÃO: Conecta o sinal "landed_on_floor" do objeto (Grabable)
	# à função que toca o SFX.
	held_object.landed_on_floor.connect(_on_object_landed)

	set_held_object_position(positions.DROP)
	held_object.object.set_deferred("freeze", false)
	held_object.object.remove_collision_exception_with(graber_object)
	grabbable_object = held_object
	held_object = null
	
# Esta função é chamada quando o sinal é emitido pelo Grabable.
func _on_object_landed():
	if drop_object_sfx:
		drop_object_sfx.play()
		
		# Recomendação de Limpeza:
		# Após tocar o som, é bom desconectar o sinal para que ele não toque
		# novamente se o objeto for empurrado no chão.
		# O objeto que está no chão agora é o 'grabbable_object' (o antigo held_object)
		if grabbable_object and grabbable_object.landed_on_floor.is_connected(_on_object_landed):
			grabbable_object.landed_on_floor.disconnect(_on_object_landed)

# Atualiza posição do objeto agarrado de acordo com seu tamanho.
func _update_held_object_position():
	if not held_object:
		return
	if held_object.is_small():
		set_held_object_position(positions.SMALL)
	else:
		set_held_object_position(positions.BIG)


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
		target_position = get_drop_safe_position(target_position, object_size.x)
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
func get_drop_safe_position(target_position:Vector2, object_size_x):
	var safe_position = Vector2.ZERO
	safe_position = target_position + Vector2(direction*(object_size_x/4), 0)
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
# ---------------------------------------------------------------------------- #
