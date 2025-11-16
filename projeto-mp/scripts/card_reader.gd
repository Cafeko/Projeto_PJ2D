# scripts/CardReader.gd
extends Activator
class_name CardReader

@export var anim: AnimatedSprite2D
@export var detection_area: Area2D

# --- Ready ---
func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	if not is_active():
		anim.play("locked")
	else:
		anim.play("unlocked")

# --- Detecção de Colisão ---
# Esta função é chamada quando um Corpo (Body) entra nesta Area2D.
func _on_body_entered(body):
	if body is Keycard and not is_active():
		var keycard_instance: Keycard = body
		
		# Mudar a animação do CardReader para "unlocked"
		if anim and anim.animation != "unlocked":
			anim.play("unlocked")
		
		# Muda estado para ativo.
		activate()
		
		# Deleta o keycard.
		keycard_instance.queue_free()
