extends Button

var current_position = Vector2()
var current_size = Vector2()

var current_screen_size = Vector2()
var start_anim_forward = false

var move_y = 50
var move_x = 50

var up_ready = false
var down_ready = false

func _ready():
	yield(get_tree(), "idle_frame")
	current_position = rect_global_position
	current_size = rect_size

func _process(delta):
	current_screen_size = OS.get_real_window_size()
	var move_changed_x = (current_screen_size.x - current_position.x + current_size.x) / move_x
	var move_changed_y = (current_screen_size.y - current_position.y + current_size.y) / move_y
	
	if start_anim_forward:
		open_btn(current_size, move_changed_x, move_changed_y)
	else:
		close_btn(current_size, move_changed_x, move_changed_y)

func open_btn(current_size, move_changed_x, move_changed_y):
	if rect_global_position.y - current_position.y / move_y> 0:
		rect_global_position.y -= current_position.y / move_y
	else:
		rect_global_position.y = 0
		up_ready = true
	if rect_size.y + (current_position.y / move_y) + move_changed_y < current_screen_size.y:
		rect_size.y += (current_position.y / move_y) + move_changed_y
	else:
		rect_size.y = current_screen_size.y
		down_ready = true
	if down_ready and up_ready:
		if rect_global_position.x - current_position.x / move_x> 0:
			rect_global_position.x -= current_position.x / move_x
		else:
			rect_global_position.x = 0
		if rect_size.x + move_changed_x + current_position.x / move_x < current_screen_size.x:
			rect_size.x += move_changed_x + current_position.x / move_x
		else:
			rect_size.x = current_screen_size.x

func close_btn(current_size, move_changed_x, move_changed_y):
	if rect_global_position.x + current_position.x / move_x< current_position.x:
		rect_global_position.x += current_position.x / move_x
	else:
		rect_global_position.x = current_position.x
		up_ready = false
	if rect_size.x - move_changed_x + (current_position.x / move_x) > current_size.x:
		rect_size.x -= move_changed_x + (current_position.x / move_x)
	else:
		rect_size.x = current_size.x
		down_ready = false

	if !down_ready and !up_ready:
		if rect_global_position.y + current_position.y / move_y < current_position.y:
			rect_global_position.y += current_position.y / move_y
		else:
			rect_global_position.y = current_position.y
		if rect_size.y - move_changed_y + (current_position.y / move_y) > current_size.y:
			rect_size.y -= move_changed_y + (current_position.y / move_y)
		else:
			rect_size.y = current_size.y

func _on_Button_pressed():
	start_anim_forward = !start_anim_forward
