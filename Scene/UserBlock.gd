extends Control

var color_good = Color(0, 0.47, 0.01)
var color_bad = Color(0.55, 0, 0)
var color_prog = Color(0.55, 0.5, 0)
var color_base = Color(0, 0, 0)

var color_clear = Color(1, 1, 1)
var color_focused = Color(0.9, 0.9, 0.9)

var color_fav_clear = Color(0.95, 0.93, 0.76)
var color_fav_focused = Color(1, 0.96, 0.56)

onready var color_rect = $ColorRect

onready var text_header = $Header
onready var image = $TextureRect
onready var text_subheader = $Subheader
onready var text_percent_work = $PercentWork

onready var http_sender = $HTTPRequest
onready var http_pict = $HTTPGetPhoto

var local_data = {}

signal is_pressed(data)


# name - имя
# tag - описание
# image - картинка
# percent - прогресс по обучалке
# admin - администраторы
# moder - модераторы
# info - информация обучения
# role - уровень доступа
# has_error - есть ошибки в прохождении
func set_data(data):
	local_data = data
	text_header.text = data["name"]
	text_subheader.text = data["tag"]
	text_percent_work.text = "%.0f%%" % data["percent"]
	if data["image"] != null and data["image"] != "" and !Global.is_offline:
		if data["image"] in Cache.image_buf:
			Global.load_pict(image, Cache.image_buf[data["image"]])
		else:
			Global.send_HTTP(http_pict, Global.url_to_link + Global.download_pict, {"name" : data["image"]})
	if data["has_error"] == true:
		text_percent_work.add_color_override("font_color", color_bad)
	elif data["percent"] == 0:
		text_percent_work.add_color_override("font_color", color_base)
	elif data["percent"] == 100:
		text_percent_work.add_color_override("font_color", color_good)
	else:
		text_percent_work.add_color_override("font_color", color_prog)
	
	if data["is_favourite"] == true:
		color_rect.color = color_fav_clear


func _on_UserBlock_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("is_pressed", local_data)
			Global.last_click = self

func _on_UserBlock_mouse_entered():
	if local_data["is_favourite"] == true:
		color_rect.color = color_fav_focused
		return 0
	color_rect.color = color_focused


func _on_UserBlock_mouse_exited():
	if local_data["is_favourite"] == true:
		color_rect.color = color_fav_clear
		return 0
	color_rect.color = color_clear

func set_favourite():
	#Изменить избранное схемы и сохранить результат
	local_data["is_favourite"] = !local_data["is_favourite"]
	if local_data["is_favourite"] == true:
		color_rect.color = color_fav_clear
	else:
		color_rect.color = color_clear
	#Поиск в списке
	if Global.test_blocks["id"] == local_data["id"]:
		Global.test_blocks["is_favourite"] = local_data["is_favourite"]
	var schema_ids = {
		"prog_id" : local_data["id"], 
		"user_id" : Global.user_id, 
		"is_favorite" : local_data["is_favourite"]}
	#print(schema_ids)
	if !Global.is_offline:
		Global.send_HTTP(http_sender, Global.url_to_link + Global.set_favorite_schema, {"data" : schema_ids})

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	Cache.is_update_user_favorite_block = true


func _on_HTTPGetPhoto_request_completed(result, response_code, headers, body):
	if response_code == 206:
		Global.load_pict(image, body)
		Cache.save_photo_to_cache(local_data["image"], body)
