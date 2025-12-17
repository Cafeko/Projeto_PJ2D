extends CharacterBody2D

class_name PlayerCopy

@onready var anim = $AnimatedSprite2D
@onready var collision_detector = $CollisionDetector
@onready var floor_detector = $FloorDetector
@onready var graber = $Graber
@onready var interactor = $Interactor

var current_anim = null
var dead : bool = false


func _ready():
	current_anim = anim.animation
	play_animation(current_anim)


# Faz a execução de uma aniamção.
func play_animation(animation):
	anim.play(animation)


# Muda direção.
func flip(valor):
	anim.flip_h = valor
	if anim.flip_h == true:
		graber.set_direction(-1)
	elif anim.flip_h == false:
		graber.set_direction(1)


# Verifica se a copia colidiu com algo.
func is_colliding():
	return len(collision_detector.get_overlapping_bodies()) > 0


# Verifica se tem um chao em baixo da copia.
func is_in_floor():
	return (len(area_hits_tilemap(floor_detector)) > 0 
	or len(floor_detector.get_overlapping_bodies()) > 0)


# Detecta se area colide com colisão de tilemap.
func area_hits_tilemap(area: Area2D, mask := 1):
	var shape = area.get_node("CollisionShape2D").shape
	var params := PhysicsShapeQueryParameters2D.new()
	
	params.shape_rid = shape.get_rid()
	params.transform = area.global_transform
	params.collision_mask = mask
	
	var space = area.get_world_2d().direct_space_state
	return space.intersect_shape(params)


# Indica se está morto ou não.
func is_dead():
	return dead


# Executada quando algo faz ele morrer.
func die():
	dead = true
	force_drop()


# Faz copia agarrar objeto.
func grab():
	graber.grab_object()


# Faz copia soltar objeto.
func drop():
	graber.drop_object()


func force_drop():
	graber.force_drop()


# Retorna se copia está agarrando ou não.
func is_grabing():
	return graber.is_holding()


# Faz copia interagir.
func interact():
	interactor.do_interaction()
