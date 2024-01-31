extends Control

onready var file_dialog = $FileDialog
onready var search_btn = $SeachBtn
onready var favorite_btn = $FavoritesBtn
onready var access_btn = $AccessBtn
# Called when the node enters the scene tree for the first time.
func _ready():
	if Cache.user_data == null:
		search_btn.disabled = true
		favorite_btn.disabled = true
		access_btn.disabled = true
	else:
		Global.is_offline = false
	$Version.text = "Ver: %d.%d.%d.%d %s" % [Global.main_ver, Global.sub_ver, Global.release_status, Global.error_fixed, Global.prefix]

func _input(event):
	if Input.is_action_just_released("ui_cancel"):
		file_dialog.hide()

func _on_ConfigBtn_pressed():
	get_tree().change_scene("res://Scene/Configurator.tscn")


func _on_SeachBtn_pressed():
	Global.is_offline = false
	get_tree().change_scene("res://Scene/Search.tscn")
	Global.type_search = 0


func _on_FavoritesBtn_pressed():
	Global.is_offline = false
	get_tree().change_scene("res://Scene/Search.tscn")
	Global.type_search = 1


func _on_ExitBtn_pressed():
	Cache.clear_data()
	get_tree().change_scene("res://Scene/Auth.tscn")


func _on_OpenBtn_pressed():
	file_dialog.popup_centered()


func _on_FileDialog_file_selected(path):
	Global.is_offline = true
	if Global.load_game(path) == 0:
		get_tree().change_scene("res://Scene/Search.tscn")

func set_online(check):
	search_btn.disabled = !check
	favorite_btn.disabled = !check
	if Global.user_role == 3:
		access_btn.disabled = !check
	else:
		access_btn.disabled = true
	Global.is_offline = !check

func get_fav_block():
	$FavBlock.get_fav_block()


func _on_AccessBtn_pressed():
	get_tree().change_scene("res://Scene/UserAccess.tscn")
