extends State

@export var idle_state : State

# Executed upon entering the state.
func enter():
	parent_object.anim.play("idle")
	parent_object.checkpoint_set_time_speed(parent_object.MEDITATION_TIME_SPEED)
	global.ui.screen_effect_fast()


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
	parent_object.checkpoint_set_time_speed(1.0)
	global.ui.screen_effect_normal()
