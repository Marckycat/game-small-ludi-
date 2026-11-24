extends Node2D

@export var carta_escena: PackedScene
@export var punto_mazo: Marker2D
@export var zona_descarte: Area2D
@export var inicial := 5
@export var maximo := 7
@export var separacion := 140.0
@export var boton_robar: Button
@export var mensaje_label: Label
@export var tiempo_visible := 1.0
@export var tiempo_fade := 0.6


var cartas: Array = []
var debe_descartar := false
var tween_mensaje: Tween


func _ready():
	boton_robar.pressed.connect(robar)
	for i in inicial:
		robar()
		await get_tree().create_timer(0.12).timeout


func robar():
	if debe_descartar:
		mostrar_aviso()
		return
	var c = carta_escena.instantiate()
	add_child(c)
	c.mano = self
	c.global_position = punto_mazo.global_position
	cartas.append(c)
	if cartas.size() > maximo:
		debe_descartar = true
	acomodar()


func acomodar(ignorar = null):
	var n = cartas.size()
	for i in n:
		var c = cartas[i]
		if c == ignorar:
			continue
		var t = i - (n - 1) / 2.0
		c.z_index = i
		c.mover_a(global_position + Vector2(t * separacion, t * t * 6), t * 0.05)


func actualizar_arrastre(carta):
	if carta.get_overlapping_areas().has(zona_descarte):
		return
	var n = cartas.size()
	var mejor := 0
	var mejor_dist := INF
	for i in n:
		var t = i - (n - 1) / 2.0
		var x = global_position.x + t * separacion
		var d = abs(carta.global_position.x - x)
		if d < mejor_dist:
			mejor_dist = d
			mejor = i
		if cartas.find(carta) != mejor:
			cartas.erase(carta)
			cartas.insert(mejor, carta)
			acomodar(carta)


func soltar_carta(carta):
	if carta.get_overlapping_areas().has(zona_descarte):
		descartar(carta)
		return
	acomodar()


func descartar(carta):
	cartas.erase(carta)
	carta.input_pickable = false
	var t = create_tween()
	t.tween_property(carta, "global_position", zona_descarte.global_position, 0.2)
	t.tween_callback(carta.queue_free)
	debe_descartar = cartas.size() > maximo
	acomodar()


func mostrar_aviso():
	if tween_mensaje:
		tween_mensaje.kill()
	mensaje_label.visible = true
	mensaje_label.modulate.a = 1.0
	tween_mensaje = create_tween()
	tween_mensaje.tween_interval(tiempo_visible)
	tween_mensaje.tween_property(mensaje_label, "modulate:a", 0.0, tiempo_fade)
	tween_mensaje.tween_callback(func(): mensaje_label.visible = false)
