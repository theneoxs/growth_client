extends Control

var user_block = preload("res://Scene/UserBlock.tscn")
var choose_name_mode = load("res://Scene/ChoosePeople.tscn")

onready var loader = $Loader
onready var list_data = $FindControl/ScrollContainer/VBoxContainer
onready var hider = $DataField/Hider
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var err_label = $FindControl/ErrLabel

onready var data_name = $DataField/TextureRect/Name
onready var data_admins = $DataField/VBoxContainer/Admins
onready var data_moders = $DataField/VBoxContainer/Moders
onready var data_descrive = $DataField/VBoxContainer/Describe
onready var data_progress = $DataField/VBoxContainer/Progress
onready var data_role = $DataField/Role
onready var data_image = $DataField/TextureRect
onready var open_btn = $DataField/HBoxContainer/OpenBtn
onready var moderate_btn = $DataField/HBoxContainer/ModerateBtn
onready var change_btn = $DataField/HBoxContainer/ChangeBtn
onready var fav_btn = $DataField/HBoxContainer/FavoriteBtn
var last_data = 0

onready var http_sender = $HTTPRequest
onready var http_get_scheme = $HTTPGetSchemaData

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.choose_user_id = null
	get_data_list()

func _input(event):
	if Input.is_action_just_released("ui_cancel") and !has_node("ChoosePeople"):
		_on_BackBtn_pressed()

func get_data_list():
	loader.visible = true
	hider.visible = true
	if Global.is_offline:
		$Timer.start()
	else:
		Global.send_HTTP(http_sender, Global.url_to_link + (Global.get_schemes if Global.type_search == 0 else Global.get_favorite_scheme) + str(Global.user_id), {}, HTTPClient.METHOD_GET)

func _on_UpdateBtn_pressed():
	for child in list_data.get_children():
		child.queue_free()
	get_data_list()


func _on_BackBtn_pressed():
	get_tree().change_scene("res://Scene/MainMenu.tscn")

#Статусы блоков: 0 - не в работе, 1 - в работе, 2 - завершено, 3 - отклонено мастером, 4 - подтверждено мастером
func _on_Timer_timeout():
	loader.visible = false
	#Список схем
	var mas = [Global.test_blocks]
	for i in mas:
		var total_counter = 0.0
		var complete_counter = 0.0
		var has_error = false
		for j in i["blocks"]:
			total_counter += 1
			if j["block_status"] == 2 or j["block_status"] == 4:
				complete_counter += 1
			elif j["block_status"] == 3:
				has_error = true
		var new_data = {
			"id" : i["id"],
			"name" : i["name"],
			"tag" : i["tag"],
			"admin" : i["admin"],
			"moders" : i["moders"],
			"info" : i["info"],
			"image" : i["image"],
			"role" : i["role"],
			"has_error" : has_error,
			"is_favourite" : i["is_favourite"],
			"percent" : complete_counter / total_counter * 100
		}
		var new_row = user_block.instance()
		list_data.add_child(new_row)
		new_row.set_data(new_data)
		new_row.connect("is_pressed", self, "open_new_data")

func load_data():
	loader.visible = false
	#Список схем
	var mas = Global.test_blocks_online
	err_label.visible = false
	if len(mas) == 0:
		err_label.visible = true
	for i in mas:
		if i["count_error"] == null:
			i["count_error"] = 0
		if i["count_success"] == null:
			i["count_success"] = 0
		if i["count_block"] == null:
			i["count_block"] = 0
		if i["is_favorite"] == null:
			i["is_favorite"] = false
		var admins = []
		var moders = []
		if str(i["id"]) in Global.users_admoders:
			admins = Global.users_admoders[str(i["id"])]["admin"]
			moders = Global.users_admoders[str(i["id"])]["moders"]
		var new_data = {
			"id" : i["id"],
			"name" : i["name"],
			"tag" : i["tag"],
			"admin" : admins,
			"moders" : moders,
			"info" : i["description"],
			"image" : i["image"],
			"role" : i["role"],
			"has_error" : false if i["count_error"] == 0 else true,
			"is_favourite" : i["is_favorite"],
			"percent" : i["count_success"] / i["count_block"] * 100 if i["count_block"] != 0 else 0
		}
		var new_row = user_block.instance()
		list_data.add_child(new_row)
		new_row.set_data(new_data)
		new_row.connect("is_pressed", self, "open_new_data")

func open_new_data(data):
	hider.visible = false
	last_data = data["id"]
	data_name.text = data["name"]
	var admin_text = ""
	for i in data["admin"]:
		admin_text += i["user_name"] + "; "
	if admin_text == "":
		admin_text += "Нет админов"
	data_admins.text = "Админы: " + admin_text
	var moders_text = ""
	for i in data["moders"]:
		moders_text += i["user_name"] + "; "
	if moders_text == "":
		moders_text += "Нет модераторов"
	data_moders.text = "Модераторы: " + moders_text
	data_descrive.bbcode_text = "Описание: " + data["info"]
	if data["image"] != null and data["image"] != "":
		if data["image"] in Cache.image_buf:
			Global.load_pict(data_image, Cache.image_buf[data["image"]])
		else:
			data_image.texture = load(Global.image_link)
	var role = "Не задано"
	if !Global.is_offline and (data["role"] == 2 or Global.user_role == 2):
		role = "Модератор"
		set_access(false, true, true)
	elif !Global.is_offline and (data["role"] == 3 or Global.user_role == 3):
		role = "Админ"
	else:
		role = "Участник"
		set_access(false, false, true)
	data_role.text = "Доступ: " + role
	fav_btn.pressed = false
	if data["is_favourite"] == true:
		fav_btn.pressed = true
	data_progress.text = "Прогресс: %.0f%%" % data["percent"]
	if data["has_error"]:
		data_progress.text += " (есть проблемы)"

func set_access(is_change, is_moder, is_read):
	open_btn.visible = is_read
	change_btn.visible = is_change
	moderate_btn.visible = is_moder


func _on_FavoriteBtn_pressed():
	if Global.last_click != null:
		Global.last_click.set_favourite()


func _on_ChangeBtn_pressed():
	Cache.is_update_user_data = true
	Global.send_HTTP(http_get_scheme, Global.url_to_link + Global.get_scheme_data, {"id" : last_data, "user_id" : Global.user_id})


func _on_ModerateBtn_pressed():
	var choose_mode = choose_name_mode.instance()
	add_child(choose_mode)
	choose_mode.get_user_list(1)
	#TODO: Добавить логику проверки в просмотр дерева


func _on_OpenBtn_pressed():
	Global.id_open = last_data
	get_tree().change_scene("res://Scene/TreeShower.tscn")


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if response_code != 200:
		Global.show_notification_screen(self, "Ошибка", "Сервис недоступен, попробуйте позже", 0, true)
	else:
		print(json_str.result)
		Global.test_blocks_online = json_str.result["data"]
		var schema_ids = []
		for i in Global.test_blocks_online:
			schema_ids.append(i["id"])
		Global.users_admoders = json_str.result["users"]
		load_data()

func go_to_auth():
	_on_BackBtn_pressed()

func _on_HTTPGetSchemaData_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if response_code != 200:
		Global.show_notification_screen(self, "Ошибка", "Сервис недоступен, попробуйте позже", 0)
	else:
		Global.convert_load_param_to_blocks(json_str.result)
		Global.correct_mode = true
		get_tree().change_scene("res://Scene/Configurator.tscn")
