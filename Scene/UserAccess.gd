extends Control

onready var name_text = $Name
onready var surname_text = $Surname
onready var pos_text = $Position
onready var branch_field = $BranchLine
onready var login_line = $Login
onready var password_line = $Password
onready var role_line = $RoleLine

onready var user_line = $UserLine

onready var http_sender = $HTTPRequest
onready var http_get = $HTTPData

onready var show_main_passwd = $Password/ShowPasswdMain

onready var loader = $Loader

var users = {}
var branch = {}
var role = {}

var is_changed = false
var last_data = 0

func _ready():
	var request = {"is_branch" : true, "is_user" : true, "is_role" : true}
	Global.send_HTTP(http_get, Global.url_to_link + Global.get_all_user_data, request)

func _process(delta):
	if Input.is_action_just_released("ui_cancel") and !has_node("Notification"):
		_on_BackBtn_pressed()


func _on_BackBtn_pressed():
	get_tree().change_scene("res://Scene/MainMenu.tscn")

func check_access():
	var err_text = ""
	if name_text.text == "":
		err_text += "- Не введено имя\n"
	if surname_text.text == "":
		err_text += "- Не введена фамилия\n"
	if pos_text.text == "":
		err_text += "- Не введена должность\n"
	if login_line.text == "":
		err_text += "- Не введен логин\n"
	if password_line.text == "":
		err_text += "- Не введен пароль\n"
	if err_text != "":
		Global.show_notification_screen(self, "Ошибка", err_text, 0)
		return -1
	else:
		return 0

func _on_SaveBtn_pressed():
	var checked_user = check_access()
	if checked_user == 0:
		var request = {
				"id" : users[user_line.selected]["id"] if last_data != 0 else 0,
				"name" : name_text.text,
				"surname" : surname_text.text,
				"position" : pos_text.text,
				"branch_id" : branch_field.get_item_id(branch_field.selected),
				"role_id" : role_line.get_item_id(role_line.selected),
				"login" : login_line.text,
				"password" : password_line.text
			}
		if last_data == 0:
			Global.send_HTTP(http_sender, Global.url_to_link + Global.registration, request)
		else:
			Global.send_HTTP(http_sender, Global.url_to_link + Global.change_user, request)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if response_code != 200:
		Global.show_notification_screen(self, "Ошибка регистрации", json_str.result["detail"], 0)
	else:
		Global.show_notification_screen(self, "Успешно", "Запрос успешно обработан", 0)
		set_changed(false)
		

func set_user_data(pos, data):
	name_text.text = data["name"]
	surname_text.text = data["surname"]
	pos_text.text = data["position"]
	branch_field.select(branch_field.get_item_index(data["branch_id"]))
	role_line.select(role_line.get_item_index(data["role_id"]))
	login_line.text = data["login"]
	password_line.text = data["password"]

func clear_data():
	name_text.text = ""
	surname_text.text = ""
	pos_text.text = ""
	branch_field.select(0)
	role_line.select(0)
	login_line.text = ""
	password_line.text = ""

func _on_HTTPData_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null:
		user_line.add_item("Новый...", 0)
		for i in json_str.result["branch"]:
			branch_field.add_item(i["name"], i["id"])
			branch[i["id"]] = i
		var counter = 1
		for i in json_str.result["user"]:
			user_line.add_item((i["name"] + " " + i["surname"]), counter)
			users[counter] = i
			counter += 1
		for i in json_str.result["role"]:
			role_line.add_item(i["name"], i["id"])
			role[i["id"]] = i
		loader.visible = false
		print(branch)
		return 0
	Global.show_notification_screen(self, "Регистрация недоступна", "Неполадки с сервером, попробуйте позже", 0, true)


func _on_ShowPasswdMain_pressed():
	if show_main_passwd.pressed == true:
		show_main_passwd.text = "(o)"
		password_line.secret = false
	else:
		show_main_passwd.text = "(|)"
		password_line.secret = true


func _on_UserLine_item_selected(index):
	if index == 0:
		clear_data()
		return 0
	if is_changed:
		Global.show_notification_screen(self, "Есть изменения", "Есть несохраненные изменения. Продолжить?", 1)
		get_node("Notification").connect("accept", self, "accept_change")
		get_node("Notification").connect("decline", self, "decline_change")
	else:
		accept_change()
	

func accept_change():
	set_user_data(user_line.selected,
		users[user_line.get_item_id(user_line.selected)]
		)
	last_data = user_line.selected
	set_changed(false)

func decline_change():
	user_line.select(last_data)

func set_changed(val):
	is_changed = val

func _on_Name_text_changed(new_text):
	set_changed(true)


func _on_Surname_text_changed(new_text):
	set_changed(true)


func _on_Position_text_changed(new_text):
	set_changed(true)


func _on_RoleLine_item_selected(index):
	set_changed(true)


func _on_Login_text_changed(new_text):
	set_changed(true)


func _on_Password_text_changed(new_text):
	set_changed(true)
