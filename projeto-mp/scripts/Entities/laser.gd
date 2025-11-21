extends Activable

@export var tile_on: TileMapLayer
@export var tile_off: TileMapLayer
@export var collision: CollisionShape2D

func _ready():

	# Conectar detecção do player
	super._ready()
	
# Chamado quando TODOS os activators ficam ativos
func active():
	# Laser DESLIGADO
	tile_on.visible = false
	tile_off.visible = true
	
	$laser_collider/CollisionShape2D.disabled = true

	#print("Laser OFF")

# Chamado quando NÃO houver activators ativos
func inactive():
	# Laser LIGADO
	tile_on.visible = true
	tile_off.visible = false
	
	$laser_collider/CollisionShape2D.disabled = false

	#print("Laser ON")
