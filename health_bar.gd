extends ProgressBar

func _ready():
	await get_tree().process_frame

	# Si estamos dentro del Player, conectarnos directamente
	var player = get_parent() as CharacterBody2D

	# Si no estamos dentro del Player, buscar en el grupo (para GameUI)
	if not player or not player.is_in_group("player"):
		var player_nodes = get_tree().get_nodes_in_group("player")
		if player_nodes.size() > 0:
			player = player_nodes[0]

	if player:
		# Verificar si tiene la señal antes de conectar
		if player.has_signal("health_changed"):
			player.health_changed.connect(_update_bar)
			max_value = player.max_health
			value = player.current_health
			print("✅ HealthBar conectada al Player. Salud inicial:", player.current_health, "/", player.max_health)
		else:
			print("❌ ERROR: El Player no tiene la señal 'health_changed'")
	else:
		print("❌ ERROR: No se encontró al Player")

func _update_bar(new_health, max_health):
	max_value = max_health
	var tween = create_tween()
	tween.tween_property(self, "value", new_health, 0.2).set_trans(Tween.TRANS_SINE)
	print("❤️ Salud actualizada:", new_health, "/", max_health)
