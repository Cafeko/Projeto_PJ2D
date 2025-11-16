extends Activator

# --- Vars ------------------------------------------------------------------- #
@export var detection_area :  Area2D
@export var anim : AnimatedSprite2D

var bodys_in_area : Array
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Adiciona corpo na lista de corpos na area de detecção.
func add_body_to_list(body):
	bodys_in_area.append(body)
	update_activator_state()


# Remove corpo da lista de corpos na area de detecção.
func remove_body(body):
	bodys_in_area.erase(body)
	update_activator_state()


# Atualiza o estado do botão caso tenha ou não corpos na area de detecção.
func update_activator_state():
	if len(bodys_in_area) > 0:
		activate()
		anim.play("Pressed")
	else:
		deactivate()
		anim.play("Not_Pressed")
# ---------------------------------------------------------------------------- #
# --- Signal Funcs ----------------------------------------------------------- #
# Executado quando for detectado que um corpo entrou na area.
func _on_body_entered(body):
	add_body_to_list(body)


# Executado quando for detectado que um corpo saiu na area.
func _on_body_exited(body):
	remove_body(body)
# ---------------------------------------------------------------------------- #
