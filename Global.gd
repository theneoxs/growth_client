extends Node

var notif_alert = preload("res://Scene/Notification.tscn")

var url_to_link = "http://127.0.0.1:8000/"
var get_user = "get_user/"
var get_schemes = "get_all_schemes/"
var get_admoder = "get_admoder/"
var set_favorite_schema = "set_favorite_schema/"
var set_favorite_block = "set_favorite_block/"
var set_block_status = "set_block_status/"
var get_block_to_schema = "select_all_block_in_schema/"
var get_all_users = "get_all_users/"
var create_schema = "create_schema/"
var get_fav_block = "select_all_favorite_block/"
var get_scheme_from_block = "get_schema_from_block/"
var get_complete_scheme = "select_all_complete_scheme/"
var get_favorite_scheme = "select_all_favorite_scheme/"
var get_user_to_scheme = "select_user_to_scheme/"
var get_scheme_data = "select_scheme/"
var update_scheme_data = "update_scheme/"
var get_all_user_data = "select_all_user_data/"
var change_user = "change_user/"
var check_create_blocks = "check_create_blocks/"

var load_pict = "load_picture/"
var download_pict = "download_picture/"

var auth = "auth/"
var registration = "registration/"
var get_all_branch = "select_all_branch/"

var user_id = "6b1d6361-ac2a-4a7c-a6af-0738057c2ed3"
var user_name = ""

var choose_user_id = null
var choose_user_name = ""
var choose_user_pos = ""

var main_ver = 1
var sub_ver = 18
var release_status = 0
var error_fixed = 1
var prefix = "(alpha)"

var image_link = "res://Resource/TestElements/photo_2023-01-04_00-30-16.jpg"

var type_search = 0

var color_common = Color(1, 1, 1)
var color_main = Color(0.9, 0.9, 1)
var color_error = Color(1, 0.87, 0.87)
var color_wait = Color(0.99, 1, 0.73)
var color_good = Color(0.78, 1, 0.78)

var users_admoders = {}
var correct_mode = false

var loaded_scheme = ""

var test_users = [
	{
			"user_id" : 123,
			"user_name" : "My test admin user"
		},
		{
			"user_id" : 4313,
			"user_name" : "My test admin 2"
		},
		{
			"user_id" : 156,
			"user_name" : "My test moderation user"
		},
		{
			"user_id" : 1,
			"user_name" : "First!"
		},
		{
			"user_id" : 12,
			"user_name" : "SEcond!!"
		}
]

var test_blocks_online = {
	"id" : 1,
	"name" : "Test test",
	"tag" : "Интересная история",
	"admin" : [
		{
			"user_id" : 123,
			"user_name" : "My test admin user"
		},
		{
			"user_id" : 4313,
			"user_name" : "My test admin 2"
		}
	],
	"moders" : [
		{
			"user_id" : 156,
			"user_name" : "My test moderation user"
		}
	],
	"info" : "Это базовая информация о курсе, с которой Вам необходимо ознакомиться",
	"image" : "res://Resource/TestElements/photo_2023-01-04_00-30-16.jpg",
	"role" : 0,
	"is_favourite" : true,
	"status" : 1,
	"count_block" : 1,
	"count_success" : 1,
	"count_error" : 1
}

var blocks_online = {}

var test_blocks = {
	"id" : 1,
	"name" : "Test test",
	"tag" : "Интересная история",
	"admin" : [
		{
			"user_id" : 123,
			"user_name" : "My test admin user"
		},
		{
			"user_id" : 4313,
			"user_name" : "My test admin 2"
		}
	],
	"moders" : [
		{
			"user_id" : 156,
			"user_name" : "My test moderation user"
		}
	],
	"info" : "Это базовая информация о курсе, с которой Вам необходимо ознакомиться",
	"image" : "res://Resource/TestElements/photo_2023-01-04_00-30-16.jpg",
	"role" : 0,
	"is_favourite" : true,
	"status" : 1,
	"blocks" : [
		{
			"block_id" : 1,
			"block_name" : "test_block_main 1",
			"block_type" : 1,
			"block_status" : 3,
			"block_data" : "Это тестовые данные по первому блоку. Рекомендую с ними ознакомиться",
			"block_rel" : null,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "J"
		},{
			"block_id" : 2,
			"block_name" : "test_block_main 2",
			"block_type" : 1,
			"block_status" : 2,
			"block_data" : "Это тестовые данные по второму блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 1,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "CTO"
		},{
			"block_id" : 3,
			"block_name" : "test_block_add 1",
			"block_type" : 2,
			"block_status" : 0,
			"block_data" : "Это тестовые данные по первому дополнительному блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 2,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "J"
		},{
			"block_id" : 4,
			"block_name" : "test_block_main 3",
			"block_type" : 1,
			"block_status" : 0,
			"block_data" : "Это тестовые данные по третьему блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 2,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "M"
		},
		{
			"block_id" : 5,
			"block_name" : "test_block_add 1",
			"block_type" : 2,
			"block_status" : 2,
			"block_data" : "Это тестовые данные по первому дополнительному блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 2,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "S"
		},
		{
			"block_id" : 6,
			"block_name" : "test_block_add 1",
			"block_type" : 2,
			"block_status" : 1,
			"block_data" : "Это тестовые данные по первому дополнительному блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 2,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "J+"
		},{
			"block_id" : 7,
			"block_name" : "test_block_add 1",
			"block_type" : 2,
			"block_status" : 2,
			"block_data" : "Это тестовые данные по первому дополнительному блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 6,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "S+"
		},
		{
			"block_id" : 88,
			"block_name" : "test_block_add 1",
			"block_type" : 2,
			"block_status" : 0,
			"block_data" : "Это тестовые данные по первому дополнительному блоку. Рекомендую с ними ознакомиться",
			"block_rel" : 6,
			"rel_media" : [],
			"is_favorite" : false,
			"level" : "TL"
		},
	]
}

var new_scheme_id = null
var blocks_to_create = []
var blocks_to_update = []
var blocks_to_delete = []

var test_data = "user://data.rmdata"
var pass_file = "hiyx0813yr981m3y9ks198ks9198s8714ys3714jse43rsdf"

var is_offline = false

func save_game(pathfile):
	var file = File.new()
	var path = pathfile as String
	file.open_encrypted_with_pass(path, File.WRITE, pass_file)
	file.store_var(to_json(test_blocks))
	file.close()
	return 0

func load_game(pathfile):
	var file = File.new()
	var path = pathfile as String
	if file.file_exists(path):
		file.open_encrypted_with_pass(path, File.READ, pass_file)
		var load_param = parse_json(file.get_var())
		file.close()
		loaded_scheme = path
		return convert_load_param_to_blocks(load_param)
	return -1

func convert_load_param_to_blocks(load_param):
	if load_param != null:
		load_param["id"] = int(load_param["id"])
		load_param["role"] = int(load_param["role"])
		load_param["status"] = int(load_param["status"])
		for i in load_param["blocks"]:
			i["block_id"] = int(i["block_id"])
			i["block_type"] = int(i["block_type"])
			if i["block_status"] != null:
				i["block_status"] = int(i["block_status"])
			if i["block_rel"] != null:
				i["block_rel"] = int(i["block_rel"])
		test_blocks = load_param
		return 0
	return -1

func load_game_with_encrypt(pathfile):
	var file = File.new()
	var path = pathfile as String
	if file.file_exists(path):
		file.open_encrypted_with_pass(path, File.READ, pass_file)
		var load_param = parse_json(file.get_var())
		file.close()
		if load_param != null:
			print(load_param)
			test_blocks = load_param
			loaded_scheme = path
			return 0
	return -1

var block = preload("res://Scene/Block.tscn")

var block_to_show = {}

var user_role = 2
var last_click = null
var id_open = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func find_children(data, id):
	var result_mas = []
	var id_for_find = [id]
	while len(id_for_find) != 0:
		for i in data:
			if i["block_rel"] == id_for_find[0] and i["block_type"] == 2:
				id_for_find.append(i["block_id"])
				result_mas.append(i)
		id_for_find.pop_front()
	return result_mas

func send_HTTP(http_sender : HTTPRequest, url : String, data : Dictionary = {}, method : int = HTTPClient.METHOD_POST, use_ssl : bool = false):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	if method == HTTPClient.METHOD_POST:
		http_sender.request(url, headers, use_ssl, method, query)
	if method == HTTPClient.METHOD_GET:
		http_sender.request(url)

func set_status_block(http_sender, block_id, block_status):
	Cache.is_update_user_data = true
	Cache.is_update_user_favorite_block = true
	var schema_ids = {
		"block_id" : block_id, 
		"user_id" : Global.user_id if Global.choose_user_id == null else Global.choose_user_id, 
		"block_status" : block_status}
	if !is_offline:
		send_HTTP(http_sender, Global.url_to_link + Global.set_block_status, {"data" : schema_ids})

func show_notification_screen(parent, header, text, type, is_exit = false):
	var alert = notif_alert.instance()
	parent.add_child(alert)
	alert.set_data({"header" : header, "text" : text, "type" : type})
	if is_exit:
		alert.connect("exit", parent, 'go_to_auth')

func load_pict(photo_rect, data):
	var img2 = Image.new()
	var img_error2 = img2.load_png_from_buffer(data)
	var preload_pict = ImageTexture.new()
	preload_pict.create_from_image(img2)
	photo_rect.texture = preload_pict
