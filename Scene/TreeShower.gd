extends Control

var block = preload("res://Scene/Block.tscn")

onready var camera = $Camera2D
var is_clicked = false
var camera_zoom = Vector2(1, 1)
var scroll_zoom = 1

var cam_position = Vector2()
var mouse_position = Vector2()

onready var diag_field = $MainField/Diagram
onready var spawnpoint = $MainField/Position2D
onready var loader = $UX/Loader
var rect_min_y = 50

onready var main_ux = $UX/Control
onready var data_panel = $UX/DataPanel
var open_desc = false

var block_to_show = {}
onready var text_header = $UX/DataPanel/VBoxContainer/Header
onready var text_status = $UX/DataPanel/VBoxContainer/Status
onready var text_progress = $UX/DataPanel/VBoxContainer/Progress
onready var text_main = $UX/DataPanel/VBoxContainer/MainText
onready var fav_btn = $UX/DataPanel/FavoriteBtn

onready var start_btn = $UX/DataPanel/StartBtn

onready var http_sender = $HTTPRequest

onready var header_name = $UX/Control/NameHeader
onready var moder_block = $UX/DataPanel/ModerBlock

onready var save_btn = $UX/Control/SaveProgressBtn

var can_move = true

var is_opened = false
var is_tabled = false

func _ready():
	print(Global.loaded_scheme)
	Global.block_to_show = {}
	cam_position = camera.position
	camera.zoom = camera_zoom*scroll_zoom
	header_name.visible = false
	save_btn.visible = false
	close_desc()
	if Global.is_offline:
		_on_Timer_timeout()
		save_btn.visible = true
	else:
		var schema_ids = {}
		if Global.choose_user_id == null:
			schema_ids = {
			"prog_id" : Global.id_open, 
			"user_id" : Global.user_id}
		else:
			schema_ids = {
			"prog_id" : Global.id_open, 
			"user_id" : Global.choose_user_id}
			header_name.text = Global.choose_user_name
			header_name.visible = true
			moder_block.visible = true
		Global.send_HTTP(http_sender, Global.url_to_link + Global.get_block_to_schema, {"data" : schema_ids})

func _process(delta):
	if Global.block_to_show != block_to_show:
		block_to_show = Global.block_to_show
		if len(block_to_show.keys()) == 0:
			close_desc()
		else:
			open_desc()
	if Input.is_action_just_released("ui_cancel") and !is_tabled:
		if is_opened:
			close_desc()
		else:
			_on_BackBtn_pressed()

func set_tabled(value):
	is_tabled = value

func _input(event):
	if event is InputEventMouseButton and can_move:
		if event.is_action_pressed("left_btn"):
			mouse_position = event.position
			is_clicked = true
		elif event.is_action_released("left_btn"):
			is_clicked = false
		if event.is_action_pressed("wheel_down") and scroll_zoom < 4:
			scroll_zoom += 0.1
			camera.zoom = camera_zoom*scroll_zoom
		if event.is_action_pressed("wheel_up") and scroll_zoom > 0.5:
			scroll_zoom -= 0.1
			camera.zoom = camera_zoom*scroll_zoom
	if is_clicked:
		if event is InputEventMouseMotion:
			var delta_pos = event.position - mouse_position
			cam_position -= delta_pos*scroll_zoom
			camera.position = cam_position
			mouse_position = event.position


func _on_BackBtn_pressed():
	get_tree().change_scene("res://Scene/MainMenu.tscn")

func generate_field(start_data):
	var start_pos = spawnpoint.global_position
	var num_block = 0
	for i in start_data["blocks"]:
		if i["block_type"] == 1:
			var childs = Global.find_children(start_data["blocks"], i["block_id"])
			var block_stat = i["block_status"]
			if block_stat == null:
				block_stat = 0
			var is_fav = i["is_favorite"]
			if is_fav == null:
				is_fav = false
			var data_row = {
				"block_id" : i["block_id"],
				"block_name" : i["block_name"],
				"block_type" : i["block_type"],
				"block_status" : int(block_stat),
				"block_data" : i["block_data"],
				"block_rel" : i["block_rel"],
				"blocks" : childs,
				"rel_media" : i["rel_media"],
				"level" : i["level"],
				"is_favorite" : is_fav
			}
			var new_row = block.instance()
			diag_field.add_child(new_row)
			new_row.set_data(data_row)
			new_row.set_global_position(Vector2(start_pos.x, start_pos.y+(rect_min_y+20)*num_block))
			num_block += 1

func _on_Timer_timeout():
	loader.visible = false
	#Список блоков в схеме
	if Global.is_offline:
		generate_field(Global.test_blocks)
	else:
		generate_field(Global.blocks_online)


func _on_MainText_meta_clicked(meta):
	OS.shell_open(meta)

#Статусы блоков: 0 - не в работе, 1 - в работе, 2 - завершено, 3 - отклонено мастером, 4 - подтверждено мастером
func open_desc():
	is_opened = true
	main_ux.rect_size.x = 600
	data_panel.visible = true
	diag_field.rect_position.x = -212
	text_header.text = block_to_show["block_name"]
	start_btn.text = "Изучать"
	text_status.text = "Статус: "
	if block_to_show["block_status"] == 1:
		text_status.text += "В работе"
		start_btn.text = "Завершить"
	elif block_to_show["block_status"] == 2:
		text_status.text += "Завершено"
	elif block_to_show["block_status"] == 3:
		text_status.text += "Отклонено мастером"
	elif block_to_show["block_status"] == 4:
		text_status.text += "Подтверждено мастером"
	else:
		text_status.text += "Не задано"
	text_progress.text = "Прогресс: %.0f%%" % block_to_show["percent"]
	text_main.bbcode_text = block_to_show["block_data"]
	if block_to_show["is_favorite"]:
		fav_btn.pressed = true
	else:
		fav_btn.pressed = false

func close_desc():
	is_opened = false
	main_ux.rect_size.x = 1024
	data_panel.visible = false
	diag_field.rect_position.x = 0


func _on_FavoriteBtn_pressed():
	block_to_show["link"].set_favorite(fav_btn.pressed)


func _on_StartBtn_pressed():
	if block_to_show["block_status"] == 1:
		text_status.text = "Статус: Завершено"
		start_btn.text = "Изучать"
		block_to_show["block_status"] = 2
		block_to_show["link"].set_status(2)
	else:
		text_status.text = "Статус: В работе"
		start_btn.text = "Завершить"
		block_to_show["link"].set_status(1)
		block_to_show["block_status"] = 1
	text_progress.text = "Прогресс: %.0f%%" % block_to_show["link"].get_percent()
	if !Global.is_offline:
		for i in Global.blocks_online["blocks"]:
			if i["block_id"] == block_to_show["block_id"]:
				i["block_status"] = block_to_show["block_status"]
				break
	else:
		for i in Global.test_blocks["blocks"]:
			if i["block_id"] == block_to_show["block_id"]:
				i["block_status"] = block_to_show["block_status"]
				break

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if response_code != 200:
		Global.show_notification_screen(self, "Ошибка", "Сервис недоступен, попробуйте позже", 0, true)
	else:
		Global.blocks_online = {"blocks" : json_str.result}
		_on_Timer_timeout()

func go_to_auth():
	_on_BackBtn_pressed()

func set_ux_visible(is_visible):
	$UX.visible = is_visible
	can_move = is_visible

func _on_TableBtn_pressed():
	is_tabled = true
	var new_screen = preload("res://Scene/TableCompetition.tscn").instance()
	add_child(new_screen)
	set_ux_visible(false)
	#new_screen.set_user_data()

func stop_move():
	can_move = false

func start_move():
	can_move = true

func _on_DeclineBtn_pressed():
	if block_to_show["block_status"] != 3:
		text_status.text = "Статус: Отклонено"
		start_btn.text = "Изучать"
		block_to_show["block_status"] = 3
		block_to_show["link"].set_status(3)
		text_progress.text = "Прогресс: %.0f%%" % block_to_show["link"].get_percent()

func _on_ApproveBtn_pressed():
	if block_to_show["block_status"] != 4:
		text_status.text = "Статус: Подтверждено мастером"
		start_btn.text = "Изучать"
		block_to_show["block_status"] = 4
		block_to_show["link"].set_status(4)
		text_progress.text = "Прогресс: %.0f%%" % block_to_show["link"].get_percent()


func _on_SaveProgressBtn_pressed():
	var res = Global.save_game(Global.loaded_scheme)
	if res != 0:
		Global.show_notification_screen($UX, "Ошибка", "Сохранение недоступно, попробуйте еще раз", 0)
	else:
		Global.show_notification_screen($UX, "Успешно", "Сохранение прошло успешно. Данные файла обновлены", 0)
