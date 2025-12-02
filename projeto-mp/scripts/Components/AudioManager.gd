extends Node

@export var sfx_volume: float = 0.8
@export var bg_music_volume: float = 2.0

# --- ÍNDICES DOS BARRAMENTOS ---
var sfx_bus_index: int = -1
var music_bus_index: int = -1

func _ready():
	# 1. Busca os índices dos canais de áudio.
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	music_bus_index = AudioServer.get_bus_index("Music") 

	# 2. Aplica o volume UMA VEZ ao iniciar, usando as variáveis exportadas.
	_apply_sfx_volume()
	_apply_music_volume()

# Aplica o volume de SFX no Barramento de Áudio.
func _apply_sfx_volume():
	if sfx_bus_index != -1:
		# Converte o valor exportado (0.0 a 1.0) para Decibéis (dB) e aplica.
		var db_value = linear_to_db(sfx_volume)
		AudioServer.set_bus_volume_db(sfx_bus_index, db_value)
		
		# Muta o Bus se o volume for zero.
		AudioServer.set_bus_mute(sfx_bus_index, sfx_volume == 0.0)

# Aplica o volume de Música no Barramento de Áudio.
func _apply_music_volume():
	if music_bus_index != -1:

		var db_value = linear_to_db(bg_music_volume)
		AudioServer.set_bus_volume_db(music_bus_index, db_value)
		
		AudioServer.set_bus_mute(music_bus_index, bg_music_volume == 0.0)
