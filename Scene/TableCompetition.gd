extends Control

var cell = preload("res://Scene/TableCell.tscn")
var table_row = preload("res://Scene/RowTable.tscn")

onready var data_table = $CanvasLayer/ScrollContainer
onready var data_column = $CanvasLayer/ScrollContainer/HBoxContainer

onready var user_text = $CanvasLayer/Control/User
onready var position_text = $CanvasLayer/Control/Position

var row_data = {}

func _ready():
	if Global.is_offline:
		genenate_table(Global.test_blocks["blocks"])
	else:
		genenate_table(Global.blocks_online["blocks"])
	var user_data = {"data" : [{"name" : "Неизвестно", "position" : "Неизвестно", "surname" : ""}]}
	if Global.choose_user_id == null:
		if Cache.user_data != null:
			user_data = Cache.user_data
	else:
		user_data = {"data" : [{"name" : Global.choose_user_name, "position" : Global.choose_user_pos, "surname" : ""}]}
	set_user_data(user_data)

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		_on_BackBtn_pressed()

func genenate_table(data):
	for i in data:
		if !(i["level"] in row_data):
			var new_column = table_row.instance()
			data_column.add_child(new_column)
			row_data[i["level"]] = new_column
			var new_cell = cell.instance()
			new_column.add_child(new_cell)
			new_cell.set_text_cell(i["level"])
		var new_cell = cell.instance()
		row_data[i["level"]].add_child(new_cell)
		new_cell.set_data(i)
		

func set_user_data(user_data = Cache.user_data):
	#TODO: Вставить пользователя при проверке
	user_text.text = user_data["data"][0]["name"] + " " + user_data["data"][0]["surname"]
	position_text.text = user_data["data"][0]["position"]

func _on_BackBtn_pressed():
	get_parent().set_ux_visible(true)
	get_parent().set_tabled(false)
	queue_free()
