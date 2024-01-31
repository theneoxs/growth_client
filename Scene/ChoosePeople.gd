extends Control

var user_row = load("res://Scene/UserRow.tscn")

onready var data_field = $CoreDesc/ScrollContainer/VBoxContainer
onready var name_label = $CoreDesc/FindByName

onready var http_sender = $HTTPRequest
onready var http_get_userlist = $HTTPUserList
onready var confirm_btn = $CoreDesc/ConfirmBtn

var control_data = []
var block_data = []
var type = 0
var mode = 0

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		_on_BackBtn_pressed()

func get_data():
	if Cache.user_list == null or Cache.is_update_user_list == true:
		Global.send_HTTP(http_sender, Global.url_to_link + Global.get_all_users, {}, HTTPClient.METHOD_GET)
	else:
		set_data(Cache.user_list)

func get_user_list(prog_id):
	confirm_btn.visible = false
	var schema_ids = { 
		"prog_id" : prog_id}
	Global.send_HTTP(http_get_userlist, Global.url_to_link + Global.get_user_to_scheme, {"data" : schema_ids})

func set_type(ind):
	type = ind

func set_control(contrl):
	control_data = contrl

func set_block(block):
	block_data = block

func set_data(data, control_data_check = control_data, block_data_check = block_data):
	clear()
	for i in data:
		var new_row = user_row.instance()
		data_field.add_child(new_row)
		i["check"] = false
		i["block"] = false
		if i["user_id"] in control_data_check:
			i["check"] = true
		if i["user_id"] in block_data_check:
			i["block"] = true
		new_row.set_data(i, mode)

func clear():
	for i in data_field.get_children():
		i.queue_free()

func _on_FindBtn_pressed():
	#Метод поиска по введенному фио среди всех пользователей и пользователей с правами
	var res = []
	if name_label.text != "":
		for i in Cache.user_list:
			if i["user_name"].find(name_label.text) != -1:
				i["check"] = false
				res.append(i)
	else:
		for i in Cache.user_list:
			i["check"] = false
			res.append(i)
	set_data(res)

func get_checked_data():
	var text_list_data = ""
	var dict_list_data = []
	for i in Cache.user_list:
		if i["user_id"] in control_data:
			text_list_data += i["user_name"] + ";\n"
			i.erase("check")
			dict_list_data.append(i)
	return [text_list_data, dict_list_data]

func set_check(check_id):
	if check_id in control_data:
		control_data.remove(get_index_massive(control_data, check_id))
	else:
		control_data.append(check_id)
	print(control_data)

func get_index_massive(mas, id):
	for i in range(len(mas)):
		if mas[i] == id:
			return i
	return -1

func _on_BackBtn_pressed():
	queue_free()

func _on_ConfirmBtn_pressed():
	var res = get_checked_data()
	if type == 0:
		Global.test_blocks["admin"] = res[1]
		get_parent().set_text_admin(res[0])
	elif type == 1:
		Global.test_blocks["moders"] = res[1]
		get_parent().set_text_moder(res[0])
	queue_free()


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	Cache.user_list = json_str.result
	Cache.is_update_user_list = false
	set_data(Cache.user_list)


func _on_HTTPUserList_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null:
		var data = json_str.result
		clear()
		for i in data:
			var new_row = user_row.instance()
			data_field.add_child(new_row)
			new_row.set_data(i, 1)
			new_row.connect("choose_user", self, "choose_user")

func choose_user(user_id, user_name):
	Global.choose_user_id = user_id
	Global.choose_user_name = user_name
	get_tree().change_scene("res://Scene/TreeShower.tscn")
	print(user_id)
