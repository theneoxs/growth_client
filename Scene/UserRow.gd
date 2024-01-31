extends Control

onready var check = $CheckUser
onready var text_id = $IDUser
onready var text_name = $NameUser

onready var pick_btn = $PickBtn

signal choose_user(user_id, user_name)

func set_data(data, mode = 0):
	if mode == 1:
		pick_btn.visible = true
		check.visible = false
	else:
		pick_btn.visible = false
		check.visible = true
		check.pressed = data["check"]
		check.disabled = data["block"]
	text_id.text = str(data["user_id"])
	text_name.text = data["user_name"]

func change_mode(new_mode):
	if new_mode == 1:
		pick_btn.visible = true
		check.visible = false
	else:
		check.visible = true
		pick_btn.visible = false

func get_checked():
	return check.pressed


func _on_CheckUser_pressed():
	get_parent().listen_check(text_id.text)


func _on_PickBtn_pressed():
	emit_signal("choose_user", text_id.text, text_name.text)
