extends Activable

# --- Vars ------------------------------------------------------------------------- #
@export var anim : AnimatedSprite2D
@export var collision : CollisionShape2D
# ---------------------------------------------------------------------------- #
# --- Activable Funcs -------------------------------------------------------- #
# Função abstrata, executada para deixar o activable ativo.
func active():
	anim.play("Open")
	collision.set_deferred("disabled", true)


# Função abstrata, executada para deixar o activable inativo.
func inactive():
	anim.play("Close")
	collision.set_deferred("disabled", false)
# ---------------------------------------------------------------------------- #
