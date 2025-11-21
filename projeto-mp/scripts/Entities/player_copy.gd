extends CharacterBody2D

class_name PlayerCopy

@onready var anim = $AnimatedSprite2D

var current_anim = null

func _ready():
	current_anim = anim.animation

func _physics_process(_delta: float):
	anim.play(current_anim)
