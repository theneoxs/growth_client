extends Control

onready var text_header = $CoreDesc/Header
onready var text_text = $CoreDesc/Text

onready var exit_type = $CoreDesc/ExitControl
onready var choose_type = $CoreDesc/ChooseControl

signal accept
signal decline

signal exit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		_on_ExitBtn_pressed()

func set_data(data):
	text_header.text = data["header"]
	text_text.text = data["text"]
	if data["type"] == 1:
		set_visible_type(false, true)
	else:
		set_visible_type(true, false)

func _on_ExitBtn_pressed():
	emit_signal("exit")
	exit_mode()


func _on_DeclineBtn_pressed():
	emit_signal("decline")
	exit_mode()

func _on_AccessBtn_pressed():
	emit_signal("accept")
	exit_mode()

func exit_mode():
	queue_free()

func set_visible_type(is_exit, is_choose):
	exit_type.visible = is_exit
	choose_type.visible = is_choose
