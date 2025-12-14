extends Control


# --- Vars ------------------------------------------------------------------- #
@export var label : Label

@onready var rec_texture = $HBoxContainer2/RecTexture
@onready var play_texture = $HBoxContainer2/PlayTexture
@onready var blink_timer : Timer = $Timer

enum textures {REC, PLAY}

var current_texture : TextureRect
var visible_time : float = 1
var invisible_time : float = 0.5
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	hide_timer()
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
func set_time(time):
	if time is float:
		label.text = "%.2f" %time
	elif time is String:
		label.text = time


func display_timer():
	set_visible(true)
	blink_timer.start(visible_time)


func hide_timer():
	set_visible(false)
	blink_timer.stop()


func update_time(time):
	set_time(time)


func set_texture(texture:textures):
	match texture:
		textures.REC:
			rec_texture.set_deferred("visible", true)
			play_texture.set_deferred("visible", false)
			current_texture = rec_texture
		textures.PLAY:
			rec_texture.set_deferred("visible", false)
			play_texture.set_deferred("visible", true)
			current_texture = play_texture
		_:
			rec_texture.set_deferred("visible", false)
			play_texture.set_deferred("visible", false)
			current_texture = null
# ---------------------------------------------------------------------------- #


func _on_timer_timeout() -> void:
	if current_texture:
		if current_texture.visible:
			current_texture.set_deferred("visible", false)
			blink_timer.start(invisible_time)
		else:
			current_texture.set_deferred("visible", true)
			blink_timer.start(visible_time)
