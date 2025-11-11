extends Area2D
class_name Grabable

@export var object : RigidBody2D
@export var shape : CollisionShape2D
@export var small_object : bool = true

func is_small():
	return small_object

func set_object_position(target_position:Vector2):
	object.global_position = target_position

func get_size():
	return shape.shape.size
