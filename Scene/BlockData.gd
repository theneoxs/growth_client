extends Control

onready var tree_root = $Tree
onready var name_line = $InfoData/NameLine
onready var desc_edit = $InfoData/DescEdit
onready var level_line = $InfoData/LevelLine

onready var new_name_line = $AddData/Backgr/NewNameLine
onready var new_desc_line = $AddData/Backgr/NewDescEdit
onready var new_level_line = $AddData/Backgr/NewLevelLine
onready var type_box = $AddData/Backgr/TypeLine
onready var rel_box = $AddData/Backgr/RelLine

onready var upd_name_line = $UpdateData/Backgr/UpdNameLine
onready var type_box_update = $UpdateData/Backgr/TypeUpdLine
onready var rel_box_update = $UpdateData/Backgr/RelUpdLine

onready var add_control = $AddData
onready var upd_control = $UpdateData

onready var http_sender = $HTTPRequest

var root_links = {}
var blocks_local = {}
var choose_row_id = null
var notification_alert = null

var unsaved_data = []
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.blocks_to_create = []
	Global.blocks_to_update = []
	Global.blocks_to_delete = []
	unsaved_data = []
	for i in Global.test_blocks["blocks"]:
		blocks_local[i["block_id"]] = i.duplicate()
	construct_tree()
	#set_rel_data(1)
	#set_rel_upd_data(1)

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		_on_BackBtn_pressed()

func construct_tree():
	tree_root.clear()
	root_links.clear()
	tree_root.create_item()
	tree_root.set_column_title(0, "ID")
	tree_root.set_column_title(1, "Название")
	tree_root.set_column_title(2, "Уровень")
	var mas = []
	var mas_data = []
	#TODO: сделать сука нормальную сортировку дерева
#	for i in blocks_local.values():
#		if i["block_type"] == 1 and i["block_rel"] == null:
#			if !(i["block_id"] in mas):
#				mas.append(i["block_id"])
#		elif i["block_type"] == 1:
#			if i["block_rel"] in mas:
#				if !(i["block_id"] in mas):
#					mas.insert(mas.find(i["block_rel"])+1, i["block_id"])
#			else:
#				var checked = true
#				var temp_mas_id = [i["block_id"]]
#				var temp_mas_rel = [i["block_rel"]]
#				while checked:
#					for j in blocks_local.values():
#						if j["block_rel"] == temp_mas_id[0] and j["block_type"] == 1:
#							temp_mas_id.insert(0, j["block_id"])
#							temp_mas_rel.insert(0, j["block_rel"])
#							break
#						elif j["block_id"] == temp_mas_rel[-1] and j["block_type"] == 1:
#							temp_mas_id.insert(len(temp_mas_id), j["block_id"])
#							temp_mas_rel.insert(len(temp_mas_id), j["block_rel"])
#							if j["block_rel"] in mas or j["block_rel"] == null:
#								checked = false
#							break
#				var last_place = mas.find(temp_mas_id[-1])
#				for j in range(1, len(temp_mas_id)):
#					mas.insert(last_place+j, temp_mas_id[len(temp_mas_id) - j])
	for i in blocks_local.values():
		if i["block_type"] == 1:
			mas_data.append({"block_id":i["block_id"], "block_rel":i["block_rel"]})
	
	for i in mas_data:
		if i["block_rel"] == null:
			mas.append(i["block_id"])
			break
	print(mas)
	var check = true
	while check:
		check = false
		for i in mas_data:
			if i["block_rel"] == mas[-1]:
				mas.append(i["block_id"])
				check = true

	for i in mas:
		root_links[i] = tree_root.create_item()
		root_links[i].set_text(0, str(blocks_local[i]["block_id"]))
		root_links[i].set_text(1, blocks_local[i]["block_name"])
		root_links[i].set_text(2, blocks_local[i]["level"])
	var later_mode = []
	for i in blocks_local.values():
		if i["block_type"] != 1:
			if !(i["block_rel"] in root_links.keys()):
				later_mode.append(i)
			else:
				root_links[i["block_id"]] = tree_root.create_item(root_links[i["block_rel"]])
				root_links[i["block_id"]].set_text(0, str(i["block_id"]))
				root_links[i["block_id"]].set_text(1, i["block_name"])
				root_links[i["block_id"]].set_text(2, i["level"])
	var counter = 0
	while len(later_mode) > 0:
		var i = later_mode[counter]
		counter += 1
		if i["block_rel"] in root_links.keys():
			root_links[i["block_id"]] = tree_root.create_item(root_links[i["block_rel"]])
			root_links[i["block_id"]].set_text(0, str(i["block_id"]))
			root_links[i["block_id"]].set_text(1, i["block_name"])
			root_links[i["block_id"]].set_text(2, i["level"])
			counter -= 1
			later_mode.remove(counter)
		if counter >= len(later_mode):
			counter = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_rel_data(type_data):
	rel_box.clear()
	if type_data == 1:
		rel_box.add_item("В начало")
	for i in blocks_local:
		if blocks_local[i]["block_type"] <= type_data:
			rel_box.add_item(blocks_local[i]["block_name"], blocks_local[i]["block_id"])

func set_rel_upd_data(type_data):
	rel_box_update.clear()
	var is_childer = get_child_block(choose_row_id)
	is_childer.append(choose_row_id)
	is_childer.append(blocks_local[choose_row_id]["block_rel"])
	if type_data == 1 and !(null in is_childer):
		rel_box_update.add_item("В начало")
	for i in blocks_local:
		if blocks_local[i]["block_type"] <= type_data and !(blocks_local[i]["block_id"] in is_childer):
			rel_box_update.add_item(blocks_local[i]["block_name"], blocks_local[i]["block_id"])

func get_child_block(parent_id):
	var mas = []
	for i in blocks_local.values():
		if i["block_rel"] == parent_id and i["block_type"] == 2:
			mas.append_array(get_child_block(i["block_id"]))
			mas.append(i["block_id"])
	return mas

func _on_BackBtn_pressed():
	queue_free()


func _on_Tree_item_selected():
	choose_row_id = int(tree_root.get_selected().get_text(0))
	name_line.text = blocks_local[choose_row_id]["block_name"]
	desc_edit.text = blocks_local[choose_row_id]["block_data"]
	level_line.text = blocks_local[choose_row_id]["level"]


func _on_SaveBtn_pressed():
	unsaved_data = []
	var check_create = []
	for i in blocks_local:
		unsaved_data.append(blocks_local[i])
		if int(blocks_local[i]["block_id"]) in Global.blocks_to_create:
			check_create.append(blocks_local[i]["block_name"])
	print(Global.blocks_to_create)
	print(Global.blocks_to_delete)
	print(Global.blocks_to_update)
	print(check_create)
	if len(check_create) == 0 or Global.is_offline == true:
		return_data()
	else:
		Global.send_HTTP(http_sender, Global.url_to_link + Global.check_create_blocks, {"name" : check_create})


func _on_Tree_nothing_selected():
	choose_row_id = null
	name_line.text = ""
	desc_edit.text = ""
	level_line.text = ""


func _on_NameLine_text_changed(new_text):
	if choose_row_id != null:
		blocks_local[choose_row_id]["block_name"] = new_text
		tree_root.get_selected().set_text(1, new_text)
		add_to_update(choose_row_id)


func _on_DescEdit_text_changed():
	if choose_row_id != null:
		blocks_local[choose_row_id]["block_data"] = desc_edit.text
		add_to_update(choose_row_id)


func _on_LevelLine_text_changed(new_text):
	if choose_row_id != null:
		blocks_local[choose_row_id]["level"] = new_text
		tree_root.get_selected().set_text(2, new_text)
		add_to_update(choose_row_id)

func add_to_update(new_id):
	if !(new_id in Global.blocks_to_create) and !(new_id in Global.blocks_to_update):
		Global.blocks_to_update.append(new_id)

func add_to_create(new_id):
	Global.blocks_to_create.append(new_id)

func add_to_delete(new_id):
	if new_id in Global.blocks_to_create:
		Global.blocks_to_create.pop_at(Global.blocks_to_create.find(new_id))
	elif choose_row_id in Global.blocks_to_update:
		Global.blocks_to_update.pop_at(Global.blocks_to_update.find(new_id))
		Global.blocks_to_delete.append(new_id)
	else:
		Global.blocks_to_delete.append(new_id)

func _on_TypeLine_item_selected(index):
	set_rel_data(index+1)


func _on_CloseBtn_pressed():
	add_control.visible = false
	#clear_data_new()

func clear_data_new(type_data = 1):
	new_desc_line.text = ""
	new_level_line.text = ""
	new_name_line.text = ""
	type_box.select(0)
	type_box.disabled = false
	set_rel_data(type_data)
	if len(blocks_local.keys()) == 0:
		print("yes")
		type_box.disabled = true

func clear_data_upd():
	type_box_update.select(0)
	set_rel_upd_data(1)

func _on_NewSaveBtn_pressed():
	var err_text = ""
	if new_name_line.text == "":
		err_text += "- Не введено название блока\n"
	if new_desc_line.text == "":
		err_text += "- Не введено описание блока\n"
	if new_level_line.text == "":
		err_text += "- Не введено уровень знаний блока\n"
	if rel_box.get_item_count() == 0:
		err_text += "- Нельзя создать блок без родителя\n"
	if err_text == "":
		var max_id = blocks_local.keys()
		max_id.sort()
		if len(max_id) == 0:
			max_id.append(0)
		var new_data = {
		"block_id" : max_id[-1]+1,
		"block_name" : new_name_line.text,
		"block_type" : type_box.selected+1,
		"block_status" : 0,
		"block_data" : new_desc_line.text,
		"block_rel" : null,
		"rel_media" : [],
		"is_favorite" : false,
		"level" : new_level_line.text
		}
		if type_box.selected == 0:
			if rel_box.selected == 0:
				for i in blocks_local.values():
					if i["block_rel"] == null:
						i["block_rel"] = new_data["block_id"]
						break
			else:
				new_data["block_rel"] = rel_box.get_item_id(rel_box.selected)
				for i in blocks_local.values():
					if i["block_rel"] == rel_box.get_item_id(rel_box.selected) and i["block_type"] == 1:
						i["block_rel"] = new_data["block_id"]
						break
		else:
			new_data["block_rel"] = rel_box.get_item_id(rel_box.selected)
		blocks_local[new_data["block_id"]] = new_data
		add_to_create(new_data["block_id"])
		construct_tree()
		_on_Tree_nothing_selected()
		_on_CloseBtn_pressed()
	else:
		show_notification("Не все данные введены", err_text)

func show_notification(header, text, type_notification = 0):
	notification_alert = Global.notif_alert.instance()
	add_child(notification_alert)
	var data_notif = {"header" : header, "text" : text, "type" : type_notification}
	notification_alert.set_data(data_notif)

func _on_NewBtn_pressed():
	add_control.visible = true
	#type_box.disabled = false
	clear_data_new()
	if rel_box.get_item_count() == 0:
		type_box.disabled = true

func _on_DeleteBtn_pressed():
	if choose_row_id != null:
		show_notification("Подтверждение", "Вы уверены, что хотите удалить блок вместе с вложенными блоками?\n\nДействие невозможно будет отменить", 1)
		notification_alert.connect("accept", self, "confirm_delete")
	else:
		show_notification("Запрещено", "Удаление невозможно: ничего не выбрано")

func confirm_delete():
	if blocks_local[choose_row_id]["block_rel"] == null:
		for i in blocks_local.values():
			if i["block_rel"] == choose_row_id and i["block_type"] == 1:
				i["block_rel"] = null
				add_to_update(i["block_id"])
	remove_child(choose_row_id)
	#blocks_local.erase(choose_row_id)
	construct_tree()
	_on_Tree_nothing_selected()
	notification_alert = null

func remove_child(parent_index):
	for i in blocks_local.values():
		if i["block_rel"] == parent_index:
			if i["block_type"] == 2:
				remove_child(i["block_id"])
			else:
				i["block_rel"] = blocks_local[choose_row_id]["block_rel"]
				add_to_update(i["block_id"])
	blocks_local.erase(parent_index)
	add_to_delete(parent_index)

func _on_UpdateBtn_pressed():
	if choose_row_id != null:
		clear_data_upd()
		upd_control.visible = true
		type_box_update.disabled = false
		upd_name_line.text = blocks_local[choose_row_id]["block_name"]
		if rel_box_update.get_item_count() == 0:
			type_box_update.disabled = true
		add_to_update(choose_row_id)


func _on_CloseUpdateBtn_pressed():
	upd_control.visible = false
	#clear_data_upd()


func _on_TypeUpdLine_item_selected(index):
	set_rel_upd_data(index+1)


func _on_NewUpdateBtn_pressed():
	connect_two_block()
	if type_box_update.selected == 0:
		if rel_box_update.selected == 0:
			for i in blocks_local.values():
				if i["block_rel"] == null:
					i["block_rel"] = choose_row_id
					add_to_update(i["block_id"])
					break
			blocks_local[choose_row_id]["block_rel"] = null
		else:
			for i in blocks_local.values():
				if i["block_rel"] == rel_box_update.get_item_id(rel_box_update.selected) and i["block_type"] == 1:
					i["block_rel"] = choose_row_id
					add_to_update(i["block_id"])
					break
			blocks_local[choose_row_id]["block_rel"] = rel_box_update.get_item_id(rel_box_update.selected)
	else:
		if blocks_local[choose_row_id]["block_rel"] == null:
			for i in blocks_local.values():
				if i["block_rel"] == choose_row_id and i["block_type"] == 1:
					i["block_rel"] = null
					add_to_update(i["block_id"])
					break
		blocks_local[choose_row_id]["block_rel"] = rel_box_update.get_item_id(rel_box_update.selected)
	blocks_local[choose_row_id]["block_type"] = type_box_update.selected+1
	add_to_update(choose_row_id)
	construct_tree()
	_on_CloseUpdateBtn_pressed()
	_on_Tree_nothing_selected()

func connect_two_block():
	for i in blocks_local.values():
		if i["block_rel"] == choose_row_id and i["block_type"] == 1:
			i["block_rel"] = blocks_local[choose_row_id]["block_rel"]
			add_to_update(i["block_id"])
			break

func return_data():
	Global.test_blocks["blocks"] = unsaved_data
	get_parent().update_block_label()
	queue_free()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json_str = JSON.parse(body.get_string_from_utf8())
	print(json_str.result)
	if response_code == 418:
		Global.show_notification_screen(self, "Ошибка наименований", json_str.result["detail"] if json_str.result != null else "", 0)
	elif response_code != 200:
		Global.show_notification_screen(self, "Ошибка", "Неизвестная ошибка, попробуйте повторить позже", 0)
	else:
		return_data()
		print("Good")
