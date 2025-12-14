extends Node2D
class_name InteractionIcon

# --- Var -------------------------------------------------------------------- #
@onready var icon = $Sprite2D
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	set_visibility(false)
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
func set_visibility(valor:bool):
	icon.set_deferred("visible", valor)
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		set_visibility(true)


func _on_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Player):
		set_visibility(false)
# ---------------------------------------------------------------------------- #
