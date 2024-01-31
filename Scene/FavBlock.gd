extends Control

var tab_data = preload("res://Scene/FavTabs.tscn")

onready var tab_container = $TabContainer
onready var http_sender = $HTTPRequest
onready var http_set_fav = $HTTPFavorite

onready var ref_rect = $ReferenceRect
onready var err_label = $Label
onready var nothing = $NothingFindLabel
onready var loader = $Loader

func _ready():
	if Cache.is_update_user_favorite_block == true:
		Cache.user_favorite_block = null
		get_fav_block()
	elif Cache.user_favorite_block != null:
		set_data()

func check_count_data():
	loader.visible = false
	if tab_container.get_child_count() == 0:
		show_nothing()

func get_fav_block():
	if Cache.user_data != null:
		var schema_ids = {"user_id" : Global.user_id}
		Global.send_HTTP(http_sender, Global.url_to_link + Global.get_fav_block, {"data" : schema_ids})
	else:
		show_err()

func show_nothing():
	loader.visible = false
	nothing.visible = true
	tab_container.visible = true
	ref_rect.visible = false
	err_label.visible = false

func show_err():
	loader.visible = false
	tab_container.visible = false
	nothing.visible = false
	ref_rect.visible = true
	err_label.visible = true

func set_data():
	var counter = 0
	for i in Cache.user_favorite_block:
		var new_tab_data = tab_data.instance()
		tab_container.add_child(new_tab_data)
		new_tab_data.set_data(i)
		#tab_container.set_tab_title(counter, name_tab)
		counter += 1
	check_count_data()

func clear_data():
	for i in tab_container.get_children():
		i.queue_free()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	if json_str.result != null and response_code == 200:
		clear_data()
		Cache.user_favorite_block = json_str.result
		Cache.is_update_user_favorite_block = false
		set_data()
	else:
		show_err()

func set_status_block(block_id, status):
	Global.set_status_block(http_set_fav, block_id, status)

func _on_HTTPFavorite_request_completed(result, response_code, headers, body):
	pass # Replace with function body.
