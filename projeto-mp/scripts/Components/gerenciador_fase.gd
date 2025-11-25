extends Node2D
class_name GerenciadorFase

# --- Vars ------------------------------------------------------------------- #
@export var fase_area : Area2D
@export var fase_objects : Array[Node2D]

var objects_initial_states : Dictionary = {}
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	fase_area.body_entered.connect(_on_body_entered)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func reset_fase():
	pass
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
func _on_body_entered(body):
	if is_instance_of(body, Player):
		global.set_current_fase(self)
# ---------------------------------------------------------------------------- #
