extends Control
## UI para la pantalla de Fase de Fortuna (apuestas y dados)
class_name FortunePhaseUI

signal fortune_finished

# -----------------------------------------------------------
# REFERENCIAS
# -----------------------------------------------------------
@onready var roller: DiceRollerControl = $DiceRollerControl if has_node("DiceRollerControl") else null
@onready var scroll_bar: VScrollBar = $VScrollBar if has_node("VScrollBar") else null
@onready var coin_label: Label = $CoinLabel if has_node("CoinLabel") else null

@onready var btn_damage: Button = $VBoxContainer/BtnDamage if has_node("VBoxContainer/BtnDamage") else null
@onready var btn_health: Button = $VBoxContainer/BtnHealth if has_node("VBoxContainer/BtnHealth") else null
@onready var btn_speed: Button = $VBoxContainer/BtnSpeed if has_node("VBoxContainer/BtnSpeed") else null

@onready var btn_confirm: Button = $BtnConfirm if has_node("BtnConfirm") else null
@onready var btn_cancel: Button = $BtnCancel if has_node("BtnCancel") else null

# -----------------------------------------------------------
# REFERENCIAS AL SISTEMA DE JUEGO
# -----------------------------------------------------------
@export var fortune_manager: FortuneRollManager = null

# -----------------------------------------------------------
# ESTADO DE LA UI
# -----------------------------------------------------------
var dice_selected: bool = false
var attribute_selected: bool = false
var bet_amount_set: bool = false
var selected_attribute: String = ""
var current_bet: int = 0

# -----------------------------------------------------------
# CICLO DE VIDA
# -----------------------------------------------------------

func _ready() -> void:
	if fortune_manager == null:
		fortune_manager = get_tree().current_scene.get_node_or_null("FortuneRollManager") as FortuneRollManager
	if fortune_manager == null:
		push_warning("FortunePhaseUI: No se encontró FortuneRollManager. Se usará el gestor inyectado desde Main si existe.")
	
	# Actualizar interfaz de monedas
	_update_coin_display()
	GameState.coins_changed.connect(_on_coins_changed)
	
	# Configurar botones de atributo
	if btn_damage:
		btn_damage.pressed.connect(_on_damage_pressed)
	if btn_health:
		btn_health.pressed.connect(_on_health_pressed)
	if btn_speed:
		btn_speed.pressed.connect(_on_speed_pressed)
	
	# Configurar barra de apuesta
	if scroll_bar:
		scroll_bar.value_changed.connect(_on_bet_value_changed)
	
	# Configurar botones de control
	if btn_confirm:
		btn_confirm.pressed.connect(_on_confirm_pressed)
	if btn_cancel:
		btn_cancel.pressed.connect(_on_cancel_pressed)
	
	_validate_and_enable_roll()

# -----------------------------------------------------------
# ACTUALIZACIONES DE MONEDAS
# -----------------------------------------------------------

func _on_coins_changed(new_amount: int) -> void:
	_update_coin_display()

func _update_coin_display() -> void:
	if coin_label:
		coin_label.text = "Monedas: %d" % GameState.coins

# -----------------------------------------------------------
# SELECCIÓN DE ATRIBUTO
# -----------------------------------------------------------

func _on_damage_pressed() -> void:
	selected_attribute = "daño"
	attribute_selected = true
	print("📍 Atributo seleccionado: Daño")
	_validate_and_enable_roll()

func _on_health_pressed() -> void:
	selected_attribute = "salud"
	attribute_selected = true
	print("📍 Atributo seleccionado: Salud")
	_validate_and_enable_roll()

func _on_speed_pressed() -> void:
	selected_attribute = "velocidad"
	attribute_selected = true
	print("📍 Atributo seleccionado: Velocidad")
	_validate_and_enable_roll()

# -----------------------------------------------------------
# APUESTA (VScrollBar)
# -----------------------------------------------------------

func _on_bet_value_changed(value: float) -> void:
	current_bet = int(value)
	bet_amount_set = (current_bet > 0)
	print("💰 Apuesta: ", current_bet)
	_validate_and_enable_roll()

# -----------------------------------------------------------
# VALIDACIÓN Y HABILITACIÓN DE DADO
# -----------------------------------------------------------

func _validate_and_enable_roll() -> void:
	var puede_tirar = (attribute_selected and bet_amount_set and current_bet <= GameState.coins)
	
	if roller:
		roller.interactive = puede_tirar
	
	if not puede_tirar:
		print("❌ Condiciones no cumplidas para tirar. Attr=%s, Bet=%d/%d" % [selected_attribute, current_bet, GameState.coins])

# -----------------------------------------------------------
# CONFIRMAR APUESTA (Tirar Dado)
# -----------------------------------------------------------

func _on_confirm_pressed() -> void:
	if not roller or not roller.interactive:
		print("❌ No se puede tirar ahora")
		return
	
	print("🎲 Tirando dado para apuesta de %d monedas..." % current_bet)
	roller.roll()
	
	# Conectar resultado
	if not roller.roll_finished.is_connected(_on_dice_roll_finished):
		roller.roll_finished.connect(_on_dice_roll_finished)

func _on_dice_roll_finished(result: Variant) -> void:
	var roll_value: int = int(result)
	print("🎲 Resultado: ", roll_value)

	if fortune_manager == null:
		push_error("FortunePhaseUI: No hay FortuneRollManager inyectado.")
		return
	
	# Ejecutar apuesta a través del FortuneRollManager
	var exito = fortune_manager.execute_roll(selected_attribute, current_bet, roll_value)
	
	if exito:
		_reset_ui()
		fortune_finished.emit()
		hide()
	else:
		print("❌ Apuesta fallida")

func _reset_ui() -> void:
	selected_attribute = ""
	attribute_selected = false
	bet_amount_set = false
	current_bet = 0
	
	if scroll_bar:
		scroll_bar.value = 0
	
	_validate_and_enable_roll()

# -----------------------------------------------------------
# CANCELAR APUESTA
# -----------------------------------------------------------

func _on_cancel_pressed() -> void:
	if fortune_manager:
		fortune_manager.cancel_roll()
	_reset_ui()
	fortune_finished.emit()
	hide()
