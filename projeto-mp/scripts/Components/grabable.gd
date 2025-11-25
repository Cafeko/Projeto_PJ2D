extends Area2D
class_name Grabable

# --- Vars ------------------------------------------------------------------- #
@export var object : RigidBody2D
@export var shape : CollisionShape2D
@export var small_object : bool = true
@export var can_be_grabed : bool = true
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	update_grabability()
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


# Update nodes to make object can be grabed or not.
func update_grabability():
	if can_be_grabed:
		shape.set_deferred("disabled", false)
	else:
		shape.set_deferred("disabled", true)


# set can_be_grabed value and update grabability.
func set_can_be_grabed(value:bool):
	can_be_grabed = value
	update_grabability()
# ---------------------------------------------------------------------------- #
