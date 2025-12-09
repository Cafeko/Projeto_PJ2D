extends Activable

# --- Vars ------------------------------------------------------------------------- #
@export var anim : AnimatedSprite2D
@export var collision : CollisionShape2D
@onready var door_open_sfx = $door_open_sfx as AudioStreamPlayer
# ---------------------------------------------------------------------------- #
# --- Activable Funcs -------------------------------------------------------- #
# Função abstrata, executada para deixar o activable ativo.
func active():
	anim.play("Open")
	door_open_sfx.play()
	collision.set_deferred("disabled", true)


# Função abstrata, executada para deixar o activable inativo.
func inactive():
	anim.play("Close")
	collision.set_deferred("disabled", false)
# ---------------------------------------------------------------------------- #
