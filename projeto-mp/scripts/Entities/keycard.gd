# scripts/keycard.gd
extends Item
class_name Keycard 

@export var anim: AnimatedSprite2D
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	if anim:
		anim.play("keycard")
# ---------------------------------------------------------------------------- #
