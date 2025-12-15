extends Control

const GAME_SCENE := "res://scene/main.tscn"


# Reinicia jogo.
func _on_reiniciar_button_pressed():
	get_tree().change_scene_to_file(GAME_SCENE)


# Fecha jogo.
func _on_sair_button_pressed():
	get_tree().quit()
