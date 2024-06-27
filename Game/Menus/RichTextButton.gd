extends Button

@export_color_no_alpha var hover_color :Color = Color(20,20,20)
@export_color_no_alpha var pressed_color :Color = Color(20,20,20)

@onready var rich_text_label = $RichTextLabel

func _on_mouse_entered():
	rich_text_label.text = rich_text_label.text.replace("base", hover_color.to_html())

func _on_mouse_exited():
	rich_text_label.text = rich_text_label.text.replace(hover_color.to_html(), "base")


func _on_button_down():
	rich_text_label.text = rich_text_label.text.replace(hover_color.to_html(), pressed_color.to_html())

func _on_button_up():
	rich_text_label.text = rich_text_label.text.replace(pressed_color.to_html(), hover_color.to_html())
