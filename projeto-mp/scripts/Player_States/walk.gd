extends State

@export var idle_state : State
@export var jump_state : State

# Executed upon entering the state.
func enter():
	parent_object.anim.play("walk")

# Executes at a rate of 60 fps.
func process_physics(_delta : float):
	parent_object.move()
	if parent_object.velocity.x == 0:
		return idle_state
	if Input.is_action_just_pressed("jump") and parent_object.is_on_floor():
		return jump_state
	return null

# Executed when recive a InputEvent.
func process_input(_event : InputEvent):
	return null

# Executed when exiting in state.
func exit():
	pass
