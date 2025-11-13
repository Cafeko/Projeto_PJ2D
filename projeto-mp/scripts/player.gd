extends CharacterBody2D

class_name Player

# --- Vars ------------------------------------------------------------------- #
@export var state_machine : StateMachine
@export var anim : AnimatedSprite2D
@export var graber : Graber

const SPEED = 50.0
const JUMP_VELOCITY = -350.0

enum direcion {LEFT, RIGHT}

var look_direction = direcion.RIGHT
var respawn_position: Vector2 = Vector2.ZERO
var can_start_recording : bool = false
# ---------------------------------------------------------------------------- #
# --- Ready and Physics Process ---------------------------------------------- #
func _ready() -> void:
	state_machine.init()
	respawn_position = global_position


func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
	if state_machine.get_current_state() == "Dead":
		return
	
	flit_to_look_side()
	
	gravity(delta)
	
	interactions_and_grab()

	move_and_slide()
# ---------------------------------------------------------------------------- #
# --- Internal Funcs --------------------------------------------------------- #
# Ajusta player de acordo com direção que está olhando.
func flit_to_look_side():
	if look_direction == direcion.LEFT:
		anim.flip_h = true
		graber.set_direction(-1)
	elif look_direction == direcion.RIGHT:
		anim.flip_h = false
		graber.set_direction(1)


# Aplica gravidade no player.
func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


# Executa interações e agarra objetos.
func interactions_and_grab():
	if Input.is_action_just_pressed("interact") and state_machine.get_current_state() != "Jump":
		if graber.is_holding() or graber.has_grabable():
			graber.grab_and_drop()
		elif can_start_recording:
			global.start_recording.emit(self)
			global.play_recording.emit()
	if Input.is_action_just_pressed("use") and graber.is_holding():
		var item = graber.get_held_grabable().get_object()
		if is_instance_of(item, Item) and item.is_usable():
			item.use_item()
# ---------------------------------------------------------------------------- #
# --- External Funcs --------------------------------------------------------- #
# Faz movimento do player.
func move():
	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction < 0:
		look_direction = direcion.LEFT
	elif direction > 0:
		look_direction = direcion.RIGHT


# Faz player ir para o estado morto.
func die_and_respawn():
	state_machine.go_to_state.emit("Dead")


# Atualiza a posição que vai respawnar.
func update_checkpoint(new_position: Vector2):
	if new_position != respawn_position:
		print("Checkpoint salvo!")
		respawn_position = new_position


# Retorna o estado atual do player para a recording_tape gravar as ações dele.
func get_record_data():
	return {"position" : self.global_position, "animation" : anim.animation,
			"flip_h": anim.flip_h}
# ---------------------------------------------------------------------------- #
