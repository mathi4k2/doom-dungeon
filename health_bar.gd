extends ProgressBar

func _ready():
	await get_tree().process_frame 
	
	# Usamos 'as CharacterBody2D' para forzar el tipo y que no dé error
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if player:
		# Verificamos si tiene la señal antes de conectar
		if player.has_signal("health_changed"):
			player.health_changed.connect(_update_bar)
			max_value = player.max_health
			value = player.current_health
		else:
			print("ERROR: El Player no tiene la señal 'health_changed'")
	else:
		print("ERROR: No se encontró al Player en el grupo 'player'")

func _update_bar(new_health, _max_health):
	max_value = _max_health
	var tween = create_tween()
	tween.tween_property(self, "value", new_health, 0.2).set_trans(Tween.TRANS_SINE)
