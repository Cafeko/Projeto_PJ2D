extends InfoBox

@onready var label : Label = $Control/Label


# Muda o texto que está sendo exibido.
func update_text(new_text:String):
	label.text = new_text
