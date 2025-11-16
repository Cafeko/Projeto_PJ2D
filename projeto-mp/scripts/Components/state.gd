# State of a state machine.
extends Node
class_name State

var parent_object : Node

# Executed upon entering the state.
func enter():
	pass

# Executes at a rate of 60 fps.
func process_physics(delta : float):
	return null

# Executed when recive a InputEvent.
func process_input(event : InputEvent):
	return null

# Executed when exiting in state.
func exit():
	pass

# Set a new parent object to the state.
func set_parent_object(new_parent):
	parent_object = new_parent
