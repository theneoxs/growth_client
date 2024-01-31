extends ColorRect

var text_info = "Получаем данные для роста"
var counter = 0
var dots = ""

func set_data(text):
	text_info = text

func _process(delta):
	if counter >= 60:
		counter = 0
		dots = ""
	if counter%20 == 0:
		dots += "."
	$Label.text = text_info + dots
	counter += 1
