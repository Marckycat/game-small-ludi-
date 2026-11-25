extends Area2D

var mano
var arrastrando := false
var offset := Vector2.ZERO
var tween: Tween
var datos: CartaData


func mover_a(pos: Vector2, rot: float = 0.0, dur: float = 0.2):
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "global_position", pos, dur)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", rot, dur)


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if tween:
			tween.kill()
		arrastrando = true
		z_index = 100
		rotation =  0
		offset = global_position - get_global_mouse_position()
		get_viewport().set_input_as_handled()


func _input(event):
	if not arrastrando:
		return
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + offset
		if mano:
			mano.actualizar_arrastre(self)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		arrastrando = false
		if mano:
			mano.soltar_carta(self)

func configurar(d: CartaData):
	datos = d
	if d.textura:
		$Sprite2D.texture = d.textura
	$Sprite2D.modulate = d.color()
	$EfectoCarta.text = d.texto_efecto()
