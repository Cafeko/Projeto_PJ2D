extends Node2D
class_name Fase

# --- Vars ------------------------------------------------------------------- #
@export var area_fase : Area2D

@onready var path = self.scene_file_path
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready() -> void:
	area_fase.body_entered.connect(_on_body_entered)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Retorna um dicionario com informaçoes da fase.
func return_info_fase():
	return {"path": path, "position": global_position}
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
func _on_body_entered(body):
	if is_instance_of(body, Player):
		global.update_current_fase.emit(self)
# ---------------------------------------------------------------------------- #
