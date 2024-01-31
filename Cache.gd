extends Node

var user_data = null
var is_update_user_data = false

var user_list = null
var is_update_user_list = false

var user_favorite_block = null
var is_update_user_favorite_block = false

var image_buf = {}
#TODO: переделать временный кэш изображений на хардкэш

func _ready():
	preload_photo()

func clear_data():
	user_data = null
	user_favorite_block = null
	user_list = null

func save_photo_to_cache(name, body):
	var path_to_cache = "user://cache/photo/"
	var path = Directory.new()
	if !path.dir_exists(path_to_cache):
		path.make_dir_recursive(path_to_cache)
	var photo = File.new()
	if !photo.file_exists(path_to_cache + name):
		photo.open(path_to_cache + name, File.WRITE)
		photo.store_buffer(body)
		photo.close()
	image_buf[name] = body

func preload_photo():
	var path_to_cache = "user://cache/photo/"
	var path = Directory.new()
	if path.dir_exists(path_to_cache):
		path.open(path_to_cache)
		path.list_dir_begin()
		var file_name = path.get_next()
		while file_name != "":
			if !path.current_is_dir():
				print("Found file: " + file_name)
				var photo = File.new()
				var load_photo = photo.open(path_to_cache + file_name, File.READ)
				image_buf[file_name] = photo.get_buffer(photo.get_len())
				photo.close()
			file_name = path.get_next()
