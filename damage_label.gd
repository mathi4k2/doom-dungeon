# DamageNumber.gd (Versión de prueba forzada)
extends Label

func display_number(value: int, pos: Vector2):
	# 1. Configuración de emergencia
	text = str(value)
	global_position = pos
	z_index = 100            # Asegura que esté por encima de todo
	top_level = true         # Desconecta la posición de cualquier padre
	modulate = Color.WHITE   # Asegura que no sea transparente
	scale = Vector2(2, 2)    # Hazlo gigante para la prueba
	
	print("Label creado con valor: ", value, " en: ", pos)

	# 2. Tween para que se mueva
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", pos.y - 100, 1.0)
	tween.parallel().tween_property(self, "modulate:a", 0, 1.0)
	tween.tween_callback(queue_free)
