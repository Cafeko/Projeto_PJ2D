extends Node

signal start_recording(checkpoint:Node)
signal finalize_recording
signal play_recording

var current_fase : GerenciadorFase


func set_current_fase(fase:GerenciadorFase):
	print("OK")
	current_fase = fase

func get_current_fase():
	return current_fase
