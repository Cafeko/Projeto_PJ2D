extends ColorRect

@onready var anim := $AnimationPlayer


func play_fade_in():
	anim.play("fade_in")


func play_fade_out():
	anim.play("fade_out")
