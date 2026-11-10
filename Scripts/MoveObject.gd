extends Area2D

var arrastrando := false
var offset := Vector2.ZERO
var pos_inicial: Vector2

func _ready():
	pos_inicial = global_position
	

func soltar():
	arrastrando = false
	var t = create_tween()
	t.tween_property(self, "global_position", pos_inicial, 0.25)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		arrastrando = true
		offset = global_position - get_global_mouse_position()
		get_viewport().set_input_as_handled()
		
func _input(event):
	if not arrastrando:
		return
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + offset
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		arrastrando = false
