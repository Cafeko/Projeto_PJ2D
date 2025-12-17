extends State

@export var idle_state : State
@export var respawn_timer : Timer
@onready var die_sfx = $die_sfx as AudioStreamPlayer

var respawn_ready : bool = false

func _ready():
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)

# Executed upon entering the state.
func enter():
	#print("Morri! Iniciando timer de respawn...")
	respawn_ready = false
	parent_object.anim.play("die")
	die_sfx.play()
	parent_object.velocity = Vector2.ZERO
	if parent_object.graber.is_holding():
		parent_object.graber.force_drop()
	global.player_died.emit()
	global.ui.transition_fade_out()
	respawn_timer.start()

# Executes at a rate of 60 fps.
func process_physics(_delta : float):
	if respawn_ready:
		return idle_state
	return null

# Executed when recive a InputEvent.
func process_input(_event : InputEvent):
	return null

# Executed when exiting in state.
func exit():
	global.ui.transition_fade_in()

func _on_respawn_timer_timeout():
	#print("Revivendo no checkpoint!")
	parent_object.global_position = parent_object.get_respawn_position()
	parent_object.safely_reset_current_fase()
	respawn_ready = true
