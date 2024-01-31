extends Control

var mini_block = preload("res://Scene/UserBlockSmall.tscn")

onready var loader_screen = $Loader
onready var error_screen = $Label
onready var data_list = $DataList
onready var header_scheme = $DataList/ScrollContainer/VBoxContainer/Header_scheme

onready var scheme_list = $DataList/ScrollContainer/VBoxContainer/RowList/VBoxContainer

onready var http_sender = $HTTPRequest
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	header_scheme.visible = false
	change_load()
	loader_screen.set_data("Получаем данные")
	if Global.is_offline and Cache.user_data == null:
		error_load()
	else:
		if Cache.user_data == null or Cache.is_update_user_data == true:
			Global.send_HTTP(http_sender, Global.url_to_link + Global.get_user + str(Global.user_id), {}, HTTPClient.METHOD_GET)
		else:
			set_data(Cache.user_data)

func set_data(data):
	for i in data["data"][0]:
		get_node("DataList/ScrollContainer/VBoxContainer/" + str(i)).text += str(data["data"][0][i])
	Global.user_role = data["data"][0]["role_id"]
	Global.user_id = data["data"][0]["id"]
	Global.user_name = data["data"][0]["name"] + " " + data["data"][0]["surname"]
	for i in data["scheme"]:
		var new_row = mini_block.instance()
		scheme_list.add_child(new_row)
		new_row.set_data(i)
		header_scheme.visible = true
	change_load()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func change_load():
	loader_screen.visible = data_list.visible
	data_list.visible = !data_list.visible

func error_load():
	error_screen.visible = true
	loader_screen.visible = false

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null:
		Cache.user_data = json_str.result
		Cache.is_update_user_data = false
		set_data(Cache.user_data)
		get_parent().set_online(true)
	else:
		error_load()
	get_parent().get_fav_block()
