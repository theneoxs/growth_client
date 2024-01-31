extends Control

var notification_alert_res = load("res://Scene/Notification.tscn")

onready var name_text = $Name
onready var surname_text = $Surname
onready var pos_text = $Position
onready var branch_field = $BranchLine
onready var login_line = $Login
onready var password_line = $Password
onready var confirm_password_line = $Password2

onready var http_sender = $HTTPRequest
onready var http_branch_get = $HTTPBranch

onready var show_main_passwd = $Password/ShowPasswdMain
onready var show_main_second = $Password2/ShowPasswdSecond

onready var loader = $Loader

func _ready():
	Global.send_HTTP(http_branch_get, Global.url_to_link + Global.get_all_branch, {}, HTTPClient.METHOD_GET)

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		_on_AuthBtn_pressed()
	if Input.is_action_just_released("ui_cancel") and !has_node("Notification"):
		_on_ExitBtn_pressed()

func _on_AuthBtn_pressed():
	var err_text = ""
	if name_text.text == "":
		err_text += """Введите имя
		"""
	if surname_text.text == "":
		err_text += """Введите фамилию
		"""
	if pos_text.text == "":
		err_text += """Введите должность
		"""
	if login_line.text == "":
		err_text += """Введите логин
		"""
	if password_line.text == "":
		err_text += """Введите пароль
		"""
	if confirm_password_line.text == "" and password_line.text != "":
		err_text += """Подтвердите пароль
		"""
	if password_line.text != confirm_password_line.text and confirm_password_line.text != "" and password_line.text != "":
		err_text += """Пароли не совпадают, проверьте корректность ввода
		"""
		
	if err_text != "":
		Global.show_notification_screen(self, "Некорректно введены данные", err_text, 0)
		return -1
	
	var reg_data = {
		"name" : name_text.text,
		"surname" : surname_text.text,
		"position" : pos_text.text,
		"branch_id" : branch_field.get_item_id(branch_field.selected),
		"role_id" : 1,
		"login" : login_line.text,
		"password" : password_line.text
	}
	Global.send_HTTP(http_sender, Global.url_to_link + Global.registration, reg_data)


func _on_ExitBtn_pressed():
	get_tree().change_scene("res://Scene/Auth.tscn")


func _on_HTTPBranch_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null:
		for i in json_str.result:
			branch_field.add_item(i["name"], i["id"])
		loader.visible = false
		return 0
	Global.show_notification_screen(self, "Регистрация недоступна", "Неполадки с сервером, попробуйте позже", 0, true)

func go_to_auth():
	get_tree().change_scene("res://Scene/Auth.tscn")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if response_code != 200:
		Global.show_notification_screen(self, "Ошибка регистрации", json_str.result["detail"], 0)
	else:
		Global.show_notification_screen(self, "Успешно", "Ваш зарегистрированный логин: " + json_str.result["new_login"] + """. 
		Вы будете перемещены на страницу авторизации""", 0, true)


func _on_ShowPasswdMain_pressed():
	if show_main_passwd.pressed == true:
		show_main_passwd.text = "(o)"
		password_line.secret = false
	else:
		show_main_passwd.text = "(|)"
		password_line.secret = true


func _on_ShowPasswdSecond_pressed():
	if show_main_second.pressed == true:
		show_main_second.text = "(o)"
		confirm_password_line.secret = false
	else:
		show_main_second.text = "(|)"
		confirm_password_line.secret = true
