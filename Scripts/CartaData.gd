class_name CartaData
extends Resource

enum Tipo { Daño, Curar, Robar }

@export var nombre := "Carta"
@export var tipo: Tipo = Tipo.Daño
@export var valor := 1
@export var textura: Texture2D
@export_multiline var descripcion := ""

func color() -> Color:
	match tipo:
		Tipo.Daño:
			return Color("e05555")
		Tipo.Curar:
			return Color("55c26b")
		Tipo.Robar:
			return Color("5593e0")
	return Color.WHITE

func texto_efecto() -> String:
	match tipo:
		Tipo.Daño:
			return "Daño %d" % valor
		Tipo.Curar:
			return "Cura %d" % valor
		Tipo.Robar:
			return "Roba %d" % valor
	return ""
