extends State

@export var idle_state : State
@export var walk_state : State
@onready var jump_sfx = $jump_sfx as AudioStreamPlayer

# Executed upon entering the state.
func enter():
	parent_object.anim.play("jump")
	jump_sfx.play()
	parent_object.velocity.y = parent_object.JUMP_VELOCITY

# Executes at a rate of 60 fps.
func process_physics(_delta : float):
	parent_object.move()
	if parent_object.is_on_floor():
		if parent_object.velocity.x == 0:
			return idle_state
		else:
			return walk_state
	return null

# Executed when recive a InputEvent.
func process_input(_event : InputEvent):
	return null

# Executed when exiting in state.
func exit():
	pass
