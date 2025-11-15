# scripts/keycard.gd
extends RigidBody2D
class_name Keycard 

@export var anim: AnimatedSprite2D

# --- Ready ---
func _ready():
	if anim:
		anim.play("keycard") 
	
	# Garante que ele comece solto e pronto para a física.
	freeze = false 

# --- Physics Process ---
func _physics_process(_delta: float):
	pass 

func use_item():
	pass
