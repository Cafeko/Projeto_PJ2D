extends ColorRect
class_name ScreenEffect

func _ready():
	set_screen_normal()


# Muda os parametros do shader para que o efeito da tela fique normal.
func set_screen_normal():
	if material is ShaderMaterial:
		material.set_shader_parameter("roll_speed", 1.0)
		material.set_shader_parameter("roll_size", 7.0)
		material.set_shader_parameter("distort_intensity", 0.004)
		material.set_shader_parameter("noise_opacity", 0.03)
		material.set_shader_parameter("noise_speed", 3.0)
		material.set_shader_parameter("static_noise_intensity", 0.01)


# Muda os parametros do shader para que o efeito da tela fique rapido.
func set_screen_fast():
	if material is ShaderMaterial:
		material.set_shader_parameter("roll_speed", 25.0)
		material.set_shader_parameter("roll_size", 10.0)
		material.set_shader_parameter("distort_intensity", 0.02)
		material.set_shader_parameter("noise_opacity", 0.1)
		material.set_shader_parameter("noise_speed", 5.0)
		material.set_shader_parameter("static_noise_intensity", 0.04)
