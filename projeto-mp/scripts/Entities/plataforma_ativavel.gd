extends Activable

# --- Vars ------------------------------------------------------------------------- #
@export var anim : AnimatedSprite2D
@export var collision : CollisionShape2D
# ---------------------------------------------------------------------------- #
# --- Activable Funcs -------------------------------------------------------- #
# Função abstrata, executada para deixar o activable ativo.
func active():
	anim.modulate.a = 1.0
	collision.set_deferred("disabled", false)


# Função abstrata, executada para deixar o activable inativo.
func inactive():
	anim.modulate.a = 0.3
	collision.set_deferred("disabled", true)
# ---------------------------------------------------------------------------- #
