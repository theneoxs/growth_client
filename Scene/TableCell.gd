extends Control

onready var color_back = $ColorRect

var data_cell = {}

func _ready():
	pass

func set_text_cell(text):
	$Label.text = text

func set_data(data):
	data_cell = data_cell
	$Label.text = data["block_name"]
	var color = data["block_status"]
	if color == null:
		color = 0
	else:
		color = int(color)
	if color == 1:
		color_back.color = Global.color_wait
	elif color == 2 or color == 4:
		color_back.color = Global.color_good
	elif color == 3:
		color_back.color = Global.color_error
	else:
		color_back.color = Global.color_common
