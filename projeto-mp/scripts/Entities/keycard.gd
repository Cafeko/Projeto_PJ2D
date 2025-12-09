# scripts/keycard.gd
extends Item
class_name Keycard 

@export var anim: AnimatedSprite2D
@export var grabable : Grabable
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	if anim:
		anim.play("keycard")
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func card_inserted():
	anim.set_deferred("visible", false)
	grabable.set_can_be_grabed(false)
# ---------------------------------------------------------------------------- #
