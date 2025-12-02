extends State

@export var idle_state : State

# Executed upon entering the state.
func enter():
	parent_object.anim.play("idle")

# Executes at a rate of 60 fps.
func process_physics(_delta : float):
	if Input.is_action_just_pressed("meditate"):
		return idle_state
	return null

# Executed when recive a InputEvent.
func process_input(_event : InputEvent):
	return null

# Executed when exiting in state.
func exit():
	pass
