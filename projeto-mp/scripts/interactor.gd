extends Area2D
class_name Interactor
# --- Vars ------------------------------------------------------------------- #
var interactable_target : Interactable
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func do_interaction(kargs:Dictionary = {}):
	if interactable_target:
		interactable_target.interact(kargs)


func set_interactable_target(target:Interactable):
	interactable_target = target


func get_interactable_target():
	return interactable_target
# ---------------------------------------------------------------------------- #
# --- On signal Funcs -------------------------------------------------------- #
func _on_area_entered(area: Area2D):
	if is_instance_of(area, Interactable):
		set_interactable_target(area)


func _on_area_exited(area: Area2D):
	if area == interactable_target:
		set_interactable_target(null)
# ---------------------------------------------------------------------------- #
