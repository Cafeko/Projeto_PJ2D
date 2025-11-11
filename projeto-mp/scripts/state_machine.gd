# State Machine that control States.
extends Node
class_name StateMachine

# --- Signal ----------------------------------------------------------------- #
signal go_to_state(new_state : String)
# ---------------------------------------------------------------------------- #
# --- Vars ------------------------------------------------------------------- #
@export var parent_object : Node
@export var initial_state : State

var current_state : State
var states_dict = {}
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	_set_states_dict()
	_set_states_parent_object()
	go_to_state.connect(_on_go_to_state)
# ---------------------------------------------------------------------------- #
# --- Execution -------------------------------------------------------------- #
func init():
	current_state = initial_state
	current_state.enter()

# Make current_state process physics.
func process_physics(delta:float):
	if current_state:
		var new_state : State = current_state.process_physics(delta)
		if new_state:
			_change_state(new_state)

# Make current_state process inputs.
func process_input(event : InputEvent):
	if current_state:
		var new_state : State = current_state.process_input(event)
		if new_state:
			_change_state(new_state)

# Return current state name
func get_current_state():
	return current_state.name

# Transitions from the current_state to a new_State
func _change_state(new_state : State):
	if current_state:
		current_state.exit()
		current_state = new_state
		current_state.enter()
# ---------------------------------------------------------------------------- #
# --- Preparation ------------------------------------------------------------ #
func _set_states_dict():
	var states = get_children()
	for state in states:
		states_dict[state.name] = state

# Set parent object to states
func _set_states_parent_object():
	for state in states_dict.values():
		if is_instance_of(state, State):
			state.set_parent_object(parent_object)
# ---------------------------------------------------------------------------- #
# --- On signal -------------------------------------------------------------- #
func _on_go_to_state(state_name : String):
	var new_state = states_dict.get(state_name)
	if new_state:
		_change_state(new_state)
# ---------------------------------------------------------------------------- #
