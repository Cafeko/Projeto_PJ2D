extends Node

@warning_ignore("unused_signal")
signal finalize_recording
@warning_ignore("unused_signal")
signal update_current_fase(fase:Fase)
@warning_ignore("unused_signal")
signal reset_current_fase
@warning_ignore("unused_signal")
signal player_died

var ui : CanvasLayer


func set_ui(node:CanvasLayer):
	ui = node


func get_ui():
	return ui
