extends Node2D

@export var carta_escena: PackedScene
@export var zona_jugar: Area2D
@export var punto_mazo: Marker2D
@export var zona_descarte: Area2D
@export var inicial := 5
@export var maximo := 7
@export var separacion := 140.0
@export var boton_robar: Button
@export var mensaje_label: Label
@export var tiempo_visible := 1.0
@export var tiempo_fade := 0.6
@export var mazo_datos : Array[CartaData]

var cartas: Array = []
var debe_descartar := false
var tween_mensaje: Tween

signal daño_hecho(cantidad)
signal curacion_hecha(cantidad)

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
	c.configurar(mazo_datos.pick_random())
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
	var zonas = carta.get_overlapping_areas()
	if zonas.has(zona_descarte):
		descartar(carta)
		return
	if zonas.has(zona_jugar):
		jugar(carta)
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

func jugar(carta):
	texto_flotante(carta.datos.texto_efecto(), carta.datos.color(), zona_jugar.global_position)
	aplicar_efecto(carta.datos)
	cartas.erase(carta)
	carta.input_pickable = false
	var t = create_tween()
	t.tween_property(carta, "global_position", zona_jugar.global_position, 0.2)
	t.tween_callback(carta.queue_free)
	debe_descartar = cartas.size() > maximo
	acomodar()

func aplicar_efecto(d: CartaData):
	match d.tipo:
		CartaData.Tipo.Daño:
			daño_hecho.emit(d.valor)
		CartaData.Tipo.Curar:
			curacion_hecha.emit(d.valor)
		CartaData.Tipo.Robar:
			for i in d.valor:
				robar()

func texto_flotante(texto: String, color, pos: Vector2):
	var l = Label.new()
	l.text = texto
	l.modulate = color
	l.add_theme_font_size_override("font_size",48)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.z_index = 200
	get_tree().current_scene.add_child(l)
	l.global_position = pos - Vector2(60, 0)
	var t = create_tween().set_parallel(true)
	t.tween_property(l, "global_position:y", pos.y - 120, 0.8)
	t.tween_property(l, "modulate:a", 0.0, 0.8).set_delay(0.3)
	t.chain().tween_callback(l.queue_free)
