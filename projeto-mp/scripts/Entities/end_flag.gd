extends Area2D

@onready var anim := $AnimatedSprite2D
@onready var end_timer := $Timer

const END_PATH = "res://scene/end.tscn"


func _ready():
	anim.play("default")



func _on_body_entered(body: Node2D):
	if is_instance_of(body, Player):
		body.set_can_act(false)
		global.ui.transition_fade_out()
		end_timer.start()


func _on_timer_timeout():
	get_tree().change_scene_to_file(END_PATH)
