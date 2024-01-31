extends Control

var notification_alert_res = load("res://Scene/Notification.tscn")
var choose_name_mode = load("res://Scene/ChoosePeople.tscn")
var config_block = load("res://Scene/ConfigBlock.tscn")

onready var based_control = $Based
onready var main_data = $MainData
onready var name_line = $MainData/NameLine
onready var tag_line = $MainData/TagLine
onready var desc_field = $MainData/DescField
onready var photo_rect = $MainData/TextureRect
onready var admin_list = $MainData/AdminList
onready var moder_list = $MainData/ModerList
onready var block_label = $MainData/BlockLabel
onready var status_line = $MainData/StatusLine
onready var text_name_label = $MainData/NameLabel

onready var save_btn = $MainData/Save

onready var http_sender = $HTTPRequest
onready var http_pict = $HTTPLoadPhoto

var max_len_name = 40

var is_loaded = false

var presave_pict = Image.new()
var is_opened_block = false

var status = {
	0 : "Черновик",
	1 : "На проверке",
	2 : "Опубликовано",
	3 : "Заблокировано"
}

func _ready():
	for i in status:
		status_line.add_item(status[i])
	#set_data()
	$MainData/NameLine.max_length = max_len_name
	if Global.correct_mode:
		show_configurator()
		Global.new_scheme_id = Global.test_blocks["id"]

func _process(delta):
	if Input.is_action_just_released("ui_cancel") and !has_node("Notification") and !has_node("ChoosePeople") and !has_node("BlockData"):
		_on_ExitBtn_pressed()

func _on_ExitBtn_pressed():
	get_tree().change_scene("res://Scene/MainMenu.tscn")

func show_configurator(show_data = true):
	set_visible_based(false)
	set_visible_main(true, show_data)
	Global.correct_mode = false

func _on_CreateBtn_pressed():
	show_configurator(false)
	clear_data()
	Global.new_scheme_id = null

func clear_data():
	name_line.text = ""
	Global.test_blocks["name"] = ""
	text_name_label.text = "Название схемы (%d/%d)" % [0, max_len_name]
	tag_line.text = ""
	Global.test_blocks["tag"] = ""
	admin_list.text = Global.user_name
	moder_list.text = ""
	Global.test_blocks["admin"] = [{"user_id" : Global.user_id, "user_name" : Global.user_name}]
	Global.test_blocks["moders"] = []
	Global.test_blocks["blocks"] = []
	Global.test_blocks["is_favourite"] = false
	Global.test_blocks["role"] = 3
	desc_field.text = ""
	Global.test_blocks["info"] = ""
	Global.test_blocks["image"] = ""
	#photo_rect.texture = ImageTexture.new()
	block_label.text = "Всего блоков: %d" % len(Global.test_blocks["blocks"])
	status_line.select(2)

func _on_LoadBtn_pressed():
	$LoadFile.popup_centered()
		
func set_visible_based(vis):
	based_control.visible = vis

func set_visible_main(vis, show_data = true):
	main_data.visible = vis
	if show_data:
		set_data()

func set_data():
	name_line.text = Global.test_blocks["name"]
	text_name_label.text = "Название схемы (%d/%d)" % [len(name_line.text), max_len_name]
	tag_line.text = Global.test_blocks["tag"]
	var admin_list_data = ""
	for i in Global.test_blocks["admin"]:
		admin_list_data += i["user_name"] + ";\n"
	admin_list.text = admin_list_data
	var moder_list_data = ""
	for i in Global.test_blocks["moders"]:
		moder_list_data += i["user_name"] + ";\n"
	moder_list.text = moder_list_data
	desc_field.text = Global.test_blocks["info"]
	if Global.test_blocks["image"] != null and Global.test_blocks["image"] != "" and !Global.is_offline:
		if Global.test_blocks["image"] in Cache.image_buf:
			Global.load_pict(photo_rect, Cache.image_buf[Global.test_blocks["image"]])
		else:
			Global.send_HTTP(http_pict, Global.url_to_link + Global.download_pict, {"name" : Global.test_blocks["image"]})
	update_block_label()
	for i in status:
		if int(Global.test_blocks["status"]) == i:
			status_line.select(i)

func update_block_label():
	block_label.text = "Всего блоков: %d" % len(Global.test_blocks["blocks"])

func _on_SaveToFile_pressed():
	var checked_scheme = check_create()
	if checked_scheme == 0:
		$SaveToFile.popup_centered()


func _on_SaveToFile_file_selected(path):
	Global.save_game(path)
	var notif_alert = notification_alert_res.instance()
	add_child(notif_alert)
	notif_alert.set_data({"header" : "Успешно", "text" : "Файл сохранен", "type" : 0})


func _on_ChoosePhotoBtn_pressed():
	$ChoosePhoto.popup_centered()


func _on_ChoosePhoto_file_selected(path):
	print(path)
	if path.split(".")[-1] == ".png":
		var img = Image.new()
		var img_error = img.load(path)
		Global.load_pict(photo_rect, img.save_png_to_buffer())
		presave_pict = img.save_png_to_buffer()
		Global.send_HTTP(http_pict, Global.url_to_link + Global.load_pict, {"data" : Array(img.save_png_to_buffer())})
		Global.show_notification_screen(self, "Внимание", "В режиме офлайн изображение может быть не сохранено", 0)
	else:
		Global.show_notification_screen(self, "Ошибка", "Выберите файл формата .png", 0)

func check_create():
	var err_text = ""
	if name_line.text == "":
		err_text += "- Не введено название схемы\n"
	if tag_line.text == "":
		err_text += "- Не введен тег схемы\n"
	if desc_field.text == "":
		err_text += "- Не введено описание блока\n"
	if len(Global.test_blocks["blocks"]) == 0:
		err_text += "- Нельзя создать схему без блоков\n"
	if err_text != "":
		Global.show_notification_screen(self, "Ошибка", err_text, 0)
		return -1
	else:
		return 0


func _on_AdminSelectedBtn_pressed():
	start_choose_mode("admin")

func start_choose_mode(type):
	var antitype = "admin"
	if type == "admin":
		antitype = "moders"
	var choose_mode = choose_name_mode.instance()
	add_child(choose_mode)
	var control_mas = []
	var block_mas = []
	for i in Global.test_blocks[type]:
		control_mas.append(i["user_id"])
	for i in Global.test_blocks[antitype]:
		block_mas.append(i["user_id"])
	if type == "admin":
		choose_mode.set_type(0)
	elif type == "moders":
		choose_mode.set_type(1)
	choose_mode.set_control(control_mas)
	choose_mode.set_block(block_mas)
	choose_mode.get_data()

func set_text_admin(text):
	admin_list.text = text

func set_text_moder(text):
	moder_list.text = text

func _on_ModerSelectedBtn_pressed():
	start_choose_mode("moders")


func _on_StatusLine_item_selected(index):
	Global.test_blocks["status"] = 2
	#TODO: допилить выбор статуса и работу по нему


func _on_LoadFile_file_selected(path):
	if Global.load_game(path) == 0:
		Global.new_scheme_id = null
		Global.is_offline = true
		show_configurator()
		save_btn.disabled = true
	else:
		var notif_alert = notification_alert_res.instance()
		add_child(notif_alert)
		notif_alert.set_data({"header" : "Ошибка при открытии файла", "text" : "Файл не найден или поврежден. Попробуйте ещё раз", "type" : 0})


func _on_BlockBtn_pressed():
	var config_block_data = config_block.instance()
	add_child(config_block_data)


func _on_NameLine_text_changed(new_text):
	text_name_label.text = "Название схемы (%d/%d)" % [len(new_text), max_len_name]
	Global.test_blocks["name"] = new_text


func _on_TagLine_text_changed(new_text):
	Global.test_blocks["tag"] = new_text


func _on_DescField_text_changed():
	Global.test_blocks["info"] = desc_field.text


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	print(json_str.result)
	var notif_alert = notification_alert_res.instance()
	add_child(notif_alert)
	if json_str.result == null:
		notif_alert.set_data({"header" : "Ошибка", "text" : "При сохранении схемы возникла ошибка. Попробуйте позже", "type" : 0})
	else:
		notif_alert.set_data({"header" : "Успешно", "text" : "Схема успешно сохранена на сервер", "type" : 0})
		Global.blocks_to_create = []
		Global.blocks_to_update = []
		Global.blocks_to_delete = []
		#notif_alert.connect("exit", self, "exit_on_menu")
		Global.new_scheme_id = int(json_str.result["new_id"])

func exit_on_menu():
	_on_ExitBtn_pressed()

func _on_Save_pressed():
	var checked_scheme = check_create()
	if checked_scheme == 0:
		if Global.new_scheme_id == null:
			Global.send_HTTP(http_sender, Global.url_to_link + Global.create_schema, Global.test_blocks)
		else:
			Global.test_blocks["updates"] = {
				"create" : Global.blocks_to_create,
				"update" : Global.blocks_to_update,
				"delete" : Global.blocks_to_delete}
			Global.send_HTTP(http_sender, Global.url_to_link + Global.update_scheme_data, Global.test_blocks)


func _on_HTTPLoadPhoto_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json_str = JSON.parse(body.get_string_from_utf8())
		if json_str.result["type"] == "save":
			Global.test_blocks["image"] = json_str.result["new_name"]
			Cache.save_photo_to_cache(Global.test_blocks["image"], presave_pict)
	elif response_code == 206:
		Global.load_pict(photo_rect, body)
		Cache.save_photo_to_cache(Global.test_blocks["image"], body)
	else:
		print('error')
