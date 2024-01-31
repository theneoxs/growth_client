extends Tabs

onready var header = $ScrollContainer/VBoxContainer/Header
onready var description = $ScrollContainer/VBoxContainer/Description
onready var level = $Level
onready var start_btn = $StatusBtn
onready var status = $ScrollContainer/VBoxContainer/Status
onready var http_sender = $HTTPRequest

var block_status = 0
var id_data = 0
var name_data = ""

func _process(delta):
	if name != name_data:
		name = name_data

func set_data(data):
	var name_tab = (data["name"].substr(0, 10) + "...") if len(data["name"]) > 10 else data["name"]
	name_data = name_tab
	name = "name_tab"
	header.text = data["name"]
	description.text = data["description"]
	level.text = "Уровень: " + data["level"]
	id_data = data["id"]
	start_btn.text = "Изучать"
	block_status = data["block_status"]
	if data["block_status"] != null:
		block_status = int(block_status)
	if block_status == 1:
		status.text = "Статус: В работе"
		start_btn.text = "Завершить"
	elif block_status == 2:
		status.text = "Статус: Завершено"
	elif block_status == 3:
		status.text = "Статус: Отклонено мастером"
	elif block_status == 4:
		status.text = "Статус: Подтверждено мастером"
	else:
		status.text = "Статус: Не задано"
	

func _on_StatusBtn_pressed():
	if block_status == 1:
		status.text = "Статус: Завершено"
		start_btn.text = "Изучать"
		block_status = 2
		get_parent().get_parent().set_status_block(id_data, block_status)
	else:
		status.text = "Статус: В работе"
		start_btn.text = "Завершить"
		block_status = 1
		get_parent().get_parent().set_status_block(id_data, block_status)


func _on_OpenSchemeBtn_pressed():
	get_parent().get_parent().loader.visible = true
	Global.send_HTTP(http_sender, Global.url_to_link + Global.get_scheme_from_block + str(id_data), {}, HTTPClient.METHOD_GET)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null and response_code == 200:
		Global.id_open = json_str.result[0]["program_id"]
		get_tree().change_scene("res://Scene/TreeShower.tscn")
	else:
		get_parent().loader.visible = false
