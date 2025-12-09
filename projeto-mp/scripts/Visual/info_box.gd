extends PanelContainer
class_name InfoBox

# Muda a visibilidade da InfoBox.
func set_visibility(valor:bool):
	self.set_deferred("visible", valor)
