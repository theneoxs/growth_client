extends VBoxContainer

onready var parent = get_parent().get_parent().get_parent()

func listen_check(id):
	parent.set_check(id)
