extends CanvasLayer

const BET_COST: int = 50
const RESET_COINS_AMOUNT: int = 200

var selected_stat: String = "daño"
var stat_values := {
	"daño": 0.0,
	"vida": 100.0,
	"velocidad": 1.0,
}

var rng := RandomNumberGenerator.new()

var damage_button: Button
var health_button: Button
var speed_button: Button
var dice_label: Label
var bet_button: Button
var coins_label: Label
var damage_value_label: Label
var health_value_label: Label
var speed_value_label: Label
var reset_button: Button

func _ready() -> void:
	rng.randomize()

	damage_button = get_node_or_null("MainHBox/LeftPanel/DamageButton")
	health_button = get_node_or_null("MainHBox/LeftPanel/HealthButton")
	speed_button = get_node_or_null("MainHBox/LeftPanel/SpeedButton")
	dice_label = get_node_or_null("MainHBox/CenterPanel/ResultLabel")
	bet_button = get_node_or_null("MainHBox/CenterPanel/BetButton")
	coins_label = get_node_or_null("MainHBox/RightPanel/CoinsLabel")
	damage_value_label = get_node_or_null("MainHBox/RightPanel/DamageValue")
	health_value_label = get_node_or_null("MainHBox/RightPanel/HealthValue")
	speed_value_label = get_node_or_null("MainHBox/RightPanel/SpeedValue")
	reset_button = get_node_or_null("ResetCoins")

	if damage_button:
		damage_button.pressed.connect(_on_damage_button_pressed)
	else:
		printerr("TestFortuneUI: no se encontró MainHBox/LeftPanel/DamageButton")

	if health_button:
		health_button.pressed.connect(_on_health_button_pressed)
	else:
		printerr("TestFortuneUI: no se encontró MainHBox/LeftPanel/HealthButton")

	if speed_button:
		speed_button.pressed.connect(_on_speed_button_pressed)
	else:
		printerr("TestFortuneUI: no se encontró MainHBox/LeftPanel/SpeedButton")

	if bet_button:
		bet_button.pressed.connect(_on_bet_pressed)
	else:
		printerr("TestFortuneUI: no se encontró MainHBox/CenterPanel/BetButton")

	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	else:
		printerr("TestFortuneUI: no se encontró ResetCoins")

	if GameState.has_signal("coins_changed"):
		GameState.coins_changed.connect(_on_coins_changed)

	_refresh_selection()
	_update_stat_labels()
	_update_bet_button()

func _get_coins() -> int:
	var value = GameState.get("coins")
	if typeof(value) == TYPE_INT:
		return value
	elif typeof(value) == TYPE_FLOAT:
		return int(value)
	return 0

func _find_player() -> Node:
	var group_nodes = get_tree().get_nodes_in_group("player")
	if group_nodes.size() > 0:
		return group_nodes[0]
	return null

func _refresh_selection() -> void:
	if damage_button:
		if selected_stat == "daño":
			damage_button.modulate = Color(0.4, 1.0, 0.4)
		else:
			damage_button.modulate = Color(1, 1, 1)

	if health_button:
		if selected_stat == "vida":
			health_button.modulate = Color(0.4, 1.0, 0.4)
		else:
			health_button.modulate = Color(1, 1, 1)

	if speed_button:
		if selected_stat == "velocidad":
			speed_button.modulate = Color(0.4, 1.0, 0.4)
		else:
			speed_button.modulate = Color(1, 1, 1)

func _update_stat_labels() -> void:
	if coins_label:
		coins_label.text = "Monedas: %d" % _get_coins()
	if damage_value_label:
		damage_value_label.text = "Daño: +%.1f" % stat_values["daño"]
	if health_value_label:
		health_value_label.text = "Vida: %.1f" % stat_values["vida"]
	if speed_value_label:
		speed_value_label.text = "Velocidad: %.2fx" % stat_values["velocidad"]

func _update_bet_button() -> void:
	if not bet_button:
		return

	var can_bet = _get_coins() >= BET_COST
	bet_button.disabled = not can_bet
	if can_bet:
		bet_button.modulate = Color(1, 1, 1)
	else:
		bet_button.modulate = Color(1, 0.4, 0.4)
	bet_button.text = "¡APOSTAR! (%d monedas)" % BET_COST

func _on_coins_changed(new_coins: int) -> void:
	_update_stat_labels()
	_update_bet_button()

func _on_damage_button_pressed() -> void:
	selected_stat = "daño"
	_refresh_selection()

func _on_health_button_pressed() -> void:
	selected_stat = "vida"
	_refresh_selection()

func _on_speed_button_pressed() -> void:
	selected_stat = "velocidad"
	_refresh_selection()

func _on_bet_pressed() -> void:
	if _get_coins() < BET_COST:
		return

	GameState.spend_coins(BET_COST)
	_update_bet_button()

	var final_roll := await _run_spin_effect()
	_apply_roll(final_roll)
	_update_stat_labels()
	_update_bet_button()

func _on_reset_pressed() -> void:
	GameState.coins = RESET_COINS_AMOUNT
	if GameState.has_signal("coins_changed"):
		GameState.coins_changed.emit(RESET_COINS_AMOUNT)
	_update_stat_labels()
	_update_bet_button()

func _run_spin_effect() -> int:
	for i in range(14):
		dice_label.text = str(rng.randi_range(1, 6))
		await get_tree().create_timer(0.06).timeout

	var result := rng.randi_range(1, 6)
	dice_label.text = str(result)
	_play_punch_effect(dice_label)
	return result

func _play_punch_effect(target: Node) -> void:
	var tween = create_tween()
	tween.tween_property(target, "scale", Vector2(1.6, 1.6), 0.12).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(target, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BOUNCE)

func _apply_roll(value: int) -> void:
	var player = _find_player()
	if player and player.has_method("modificar_stat"):
		player.modificar_stat(selected_stat, value)
		stat_values["daño"] = player.bonus_damage if player.has_property("bonus_damage") else stat_values["daño"]
		stat_values["vida"] = player.max_health if player.has_property("max_health") else stat_values["vida"]
		stat_values["velocidad"] = player.speed_multiplier if player.has_property("speed_multiplier") else stat_values["velocidad"]
	else:
		match selected_stat:
			"daño":
				stat_values["daño"] += value
			"vida":
				stat_values["vida"] += value
			"velocidad":
				stat_values["velocidad"] = max(0.5, stat_values["velocidad"] + value / 100.0)

	if GameState.has_method("record_stat_upgrade"):
		GameState.record_stat_upgrade(selected_stat, value)
