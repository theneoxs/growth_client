extends Control

var notification_alert_res = load("res://Scene/Notification.tscn")

onready var login_text = $Login
onready var password_text = $Password

onready var error_responce = $AuthResponce

onready var http_sender = $HTTPRequest

func _ready():
	error_responce.visible = false

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		_on_AuthBtn_pressed()

func _on_AuthBtn_pressed():
	if login_text.text == "":
		show_error_screen("Введите логин")
		return -1
		
	if password_text.text == "":
		show_error_screen("Введите пароль")
		return -1
		
	var data = {
		"login" : login_text.text,
		"password" : password_text.text
	}
	Global.send_HTTP(http_sender, Global.url_to_link + Global.auth, data)

func show_error_screen(data):
	error_responce.visible = true
	error_responce.text = data

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null:
		if response_code != 200:
			show_error_screen(json_str.result["detail"])
		else:
			error_responce.visible = false
			Global.user_id = json_str.result["detail"]
			get_tree().change_scene("res://Scene/MainMenu.tscn")
		return 0
	Global.show_notification_screen(self, "Авторизация недоступна", "Неполадки с сервером, попробуйте позже", 0)


func _on_ExitBtn_pressed():
	get_tree().quit()


func _on_RegBtn_pressed():
	get_tree().change_scene("res://Scene/Registration.tscn")
