extends Control

# Caminho da cena inicial do jogo
const GAME_SCENE := "res://scene/main.tscn"

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file(GAME_SCENE)

	if event is InputEventScreenTouch and event.pressed:
		get_tree().change_scene_to_file(GAME_SCENE)

	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file(GAME_SCENE)
