extends Area2D
class_name Grabable

# --- Vars ------------------------------------------------------------------- #
@export var object : RigidBody2D
@export var shape : CollisionShape2D
@export var small_object : bool = true
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Retorna se o grabable é pequeno ou não.
func is_small():
	return small_object


# Muda o objeto do grabable para a posição indicada.
func set_object_position(target_position:Vector2):
	object.global_position = target_position


# Retorna o tamanho do shape do grabable.
func get_size():
	return shape.shape.size


# Retorna objeto do grabable.
func get_object():
	return object
# ---------------------------------------------------------------------------- #
