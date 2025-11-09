extends RigidBody2D
@onready var player: CharacterBody2D = $"../player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body: Node) -> void:
	if body == player:
		print("O player colidiu com o botão!")
