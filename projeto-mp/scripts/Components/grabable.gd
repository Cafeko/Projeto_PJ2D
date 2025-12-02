extends Area2D
class_name Grabable

# --- Vars ------------------------------------------------------------------- #
@export var object : RigidBody2D
@export var shape : CollisionShape2D
@export var small_object : bool = true
@export var can_be_grabed : bool = true

# O Graber vai se conectar a este sinal
signal landed_on_floor

# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	update_grabability()
	# CONEXÃO: Conecta o sinal nativo do RigidBody2D a uma função interna
	# Nota: Certifique-se que o RigidBody2D.contact_monitor esteja ligado (true)
	# e que ele tenha pelo menos 1 contato máximo (contacts_reported).
	object.body_entered.connect(_on_object_body_entered)
	
# --- NOVO: Função para escutar a colisão física ---
func _on_object_body_entered(body: Node2D):
	# 1. Verifica se não é o Player que está colidindo.
	# 2. Verifica se o objeto não está congelado (ou seja, se ele foi solto).
	if not object.freeze:
		
		# IMPORTANTE: Só emitimos o sinal UMA VEZ para não tocar o som 
		# continuamente enquanto o objeto estiver parado no chão.
		# A melhor forma de garantir isso é desconectar o sinal depois de tocar o som,
		# mas por simplicidade inicial, vamos apenas emitir.
		
		landed_on_floor.emit()
		
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Retorna se o grabable é pequeno ou não.
func is_small():
	return small_object


# Muda o objeto do grabable para a posição indicada.
func set_object_position(target_position:Vector2):
	object.global_position = target_position


# Retorna o tamanho do shape do grabable.
func get_size():
	return shape.shape.size


# Retorna objeto do grabable.
func get_object():
	return object


# Update nodes to make object can be grabed or not.
func update_grabability():
	if can_be_grabed:
		shape.set_deferred("disabled", false)
	else:
		shape.set_deferred("disabled", true)


# set can_be_grabed value and update grabability.
func set_can_be_grabed(value:bool):
	can_be_grabed = value
	update_grabability()
# ---------------------------------------------------------------------------- #
