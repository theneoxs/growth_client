extends Control

onready var color_rect = $ColorRect

onready var text_header = $Header
onready var image = $TextureRect

onready var http_sender = $HTTPRequest
onready var http_pict = $HTTPGetPict

var local_data = {}

func set_data(data):
	local_data = data
	text_header.text = data["name"]
	if data["image"] != null and data["image"] != "":
		if data["image"] in Cache.image_buf:
			Global.load_pict(image, Cache.image_buf[data["image"]])
		else:
			print("send")
			Global.send_HTTP(http_pict, Global.url_to_link + Global.download_pict, {"name" : data["image"]})


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	pass # Replace with function body.


func _on_HTTPGetPict_request_completed(result, response_code, headers, body):
	print("complete")
	if response_code == 206:
		Global.load_pict(image, body)
		Cache.save_photo_to_cache(local_data["image"], body)
