extends Label
## UI simple para mostrar monedas recolectadas

func _ready() -> void:
	# Actualizar inicial
	text = "💰 Monedas: %d" % GameState.coins
	
	# Conectar cambios
	GameState.coins_changed.connect(_on_coins_changed)
	
	print("✅ CoinDisplay listo. Monedas iniciales:", GameState.coins)

func _on_coins_changed(new_amount: int) -> void:
	text = "💰 Monedas: %d" % new_amount
	print("💰 Monedas actualizadas: ", new_amount)
	
	# Efecto visual de cambio
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
