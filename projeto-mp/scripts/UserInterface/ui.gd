extends CanvasLayer

# --- Vars ------------------------------------------------------------------- #
@export var recording_timer : Control
@export var screen_effect : ScreenEffect
@export var transition_rect : ColorRect
# ---------------------------------------------------------------------------- #
# --- Ready ------------------------------------------------------------------ #
func _ready():
	global.set_ui(self)
	set_visible(true)
# ---------------------------------------------------------------------------- #
# --- Funcs ------------------------------------------------------------------ #
# Faz o timer da gravação de ações aparecer.
func display_recording_timer():
	recording_timer.display_timer()


# Faz o timer da gravação de ações desaparecer.
func hide_recording_timer():
	recording_timer.hide_timer()


# Atualiza o valor do timer da gravação de ações.
func update_recording_timer(time):
	if time == null or time < 0.0:
		time = 0.0
	recording_timer.update_time(time)


# Mostra textura que indica gravando junto do timer.
func display_rec_texture():
	recording_timer.set_texture(recording_timer.textures.REC)


# Mostra textura que indica reproduzindo junto do timer. 
func display_play_texture():
	recording_timer.set_texture(recording_timer.textures.PLAY)


# Muda efeito para o modo normal.
func screen_effect_normal():
	screen_effect.set_screen_normal()


# Muda efeito para o modo rapido.
func screen_effect_fast():
	screen_effect.set_screen_fast()


# Toca o efeito de fade in na tela.
func transition_fade_in():
	if transition_rect.has_method("play_fade_in"):
		transition_rect.play_fade_in()


# Toca o efeito de fade out na tela.
func transition_fade_out():
	if transition_rect.has_method("play_fade_out"):
		transition_rect.play_fade_out()
# ---------------------------------------------------------------------------- #
