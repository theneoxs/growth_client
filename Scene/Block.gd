extends Control

var empty_star = preload("res://Resource/icons8-pixel-star-50.png")
var star = preload("res://Resource/icons8-pixel-star-48.png")

onready var back_color = $ColorRect
onready var progress_bar = $Progress
onready var text_header = $Header
onready var child_zone = $ChildZone
onready var star_rect = $Star
onready var text_level = $Level

onready var http_sender = $HTTPRequest

var block_id = 0
var childs = {}
var block_name = ""
var block_data = ""
var block_status = 0
var rel_media = []
var total_counter = 1
var complete_counter = 0
var has_error = false
var is_fav = false
var block_type = 0

var open_block = false
var leveled = "J"

var block_to_show = {}

func set_data(data):
	name = str(data["block_id"])
	text_header.text = data["block_name"]
	block_id = data["block_id"]
	block_name = data["block_name"]
	block_data = data["block_data"]
	block_status = data["block_status"]
	rel_media = data["rel_media"]
	block_type = data["block_type"]
	is_fav = data["is_favorite"]
	if block_status == 3:
		has_error = true
	elif block_status == 2 or block_status == 4:
		complete_counter += 1
	set_color_block()
	set_star()
	for j in data["blocks"]:
		total_counter += 1
		var bl_stat = j["block_status"]
		if bl_stat == null:
			bl_stat = 0
		j["block_status"] = int(bl_stat)
		if j["block_status"] == 2 or j["block_status"] == 4:
			complete_counter += 1
		elif j["block_status"] == 3:
			has_error = true
	check_progress_bar()
	if has_error:
		on_error()
	childs = data["blocks"]
	leveled = data["level"]
	text_level.text = leveled

func _on_Block_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_btn"):
			block_to_show = {
		"block_id" : block_id,
		"block_name" : block_name,
		"block_status" : block_status,
		"block_data" : block_data,
		"rel_media" : rel_media,
		"percent" : get_percent(),
		"is_favorite" : is_fav,
		"level" : leveled,
		"link" : self
	}
			if open_block and len(Global.block_to_show.keys()) > 0 and Global.block_to_show["block_id"] == block_id:
				close_child()
			else:
				if open_block:
					show_data()
				else:
					open_child()
		

func generate_child():
	var num_block = 0
	for i in childs:
		if i["block_rel"] == block_id:
			var childrens = Global.find_children(childs, i["block_id"])
			var data_row = {
				"block_id" : i["block_id"],
				"block_name" : i["block_name"],
				"block_type" : i["block_type"],
				"block_status" : i["block_status"],
				"block_data" : i["block_data"],
				"blocks" : childrens,
				"rel_media" : i["rel_media"],
				"level" : i["level"],
				"is_favorite" : i["is_favorite"]
			}
			var new_row = Global.block.instance()
			child_zone.add_child(new_row)
			new_row.set_data(data_row)
			new_row.rect_position = Vector2(rect_min_size.x+20, (rect_min_size.y+20)*num_block)
			num_block += 1

func open_child():
	for i in get_parent().get_children():
		if i.open_block:
			i.close_child()
	generate_child()
	open_block = true
	show_data()

func show_data():
	Global.block_to_show = block_to_show

func close_child():
	for i in child_zone.get_children():
		i.queue_free()
	open_block = false
	Global.block_to_show = {}

func check_progress_bar():
	if complete_counter > 0:
		progress_bar.visible = true
		progress_bar.value = get_percent()
	else:
		progress_bar.visible = false

func set_complete(count, is_counter = true):
	if is_counter:
		complete_counter += count
	else:
		complete_counter = count
	if block_status != 3:
		check_progress_bar()
	if get_parent().name != "Diagram":
		get_parent().get_parent().set_complete(count)
	#TODO: Запрос на установку готовности блока

func set_status(status):
	if (block_status == 2 or block_status == 4) and (status == 1 or status == 3):
		set_complete(-1)
	elif (block_status == 1 or block_status == 3 or block_status == 0) and (status == 2 or status == 4):
		set_complete(1)
	block_status = status
	Global.set_status_block(http_sender, block_id, block_status)
	set_color_block()
	#Изменить статус и сохранить результат
	if Global.is_offline:
		for i in Global.test_blocks["blocks"]:
			if i["block_id"] == block_id:
				i["block_status"] = status
				break
	else:
		for i in Global.blocks_online["blocks"]:
			if i["block_id"] == block_id:
				i["block_status"] = status
				break
	

func on_error():
	back_color.color = Global.color_error
	progress_bar.modulate = Global.color_error
	#progress_bar.visible = false

func set_color_block():
	if block_status == 1 or block_status == 4:
		back_color.color = Global.color_wait
		progress_bar.modulate = Global.color_common
		check_progress_bar()
	elif block_status == 3:
		on_error()
	elif block_type == 1:
		back_color.color = Global.color_main
	else:
		back_color.color = Global.color_common

func set_favorite(fav):
	is_fav = fav
	#Изменить избранное и сохранить результат
	for i in Global.test_blocks["blocks"]:
		if i["block_id"] == block_id:
			i["is_favorite"] = fav
			break
	set_star()
	var schema_ids = {
		"block_id" : block_id, 
		"user_id" : Global.user_id, 
		"is_favorite" : fav}
	if !Global.is_offline:
		Global.send_HTTP(http_sender, Global.url_to_link + Global.set_favorite_block, {"data" : schema_ids})
		Cache.is_update_user_favorite_block = true

func set_star():
	if is_fav:
		star_rect.texture = star
	else:
		star_rect.texture = empty_star

func get_percent():
	return float(complete_counter)/float(total_counter)*100


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	pass # Replace with function body.
