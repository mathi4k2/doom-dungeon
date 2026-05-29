extends Node
## Gestor del sistema de apuestas y tiradas de dados
class_name FortuneRollManager

# -----------------------------------------------------------
# SEÑALES
# -----------------------------------------------------------
signal roll_started
signal roll_completed(stat_id: String, amount_bet: int, roll_result: int, final_bonus: float)

# -----------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------
@export var bet_multiplier: float = 1.5  # Multiplicador: apuesta * resultado = bonificación

# -----------------------------------------------------------
# ESTADO ACTUAL
# -----------------------------------------------------------
var active_player: CharacterBody2D = null
var current_roll_data: Dictionary = {}

# -----------------------------------------------------------
# CICLO DE VIDA
# -----------------------------------------------------------

func _ready() -> void:
	# Buscamos el jugador en la escena
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		active_player = player_nodes[0]
	
	if not active_player:
		push_warning("FortuneRollManager: No se encontró jugador en grupo 'player'")

# -----------------------------------------------------------
# MÉTODO PÚBLICO: INICIAR TIRADA
# -----------------------------------------------------------

## Inicia el flujo de apuesta
func start_fortune_roll() -> void:
	if not active_player:
		push_error("FortuneRollManager: No hay jugador asignado")
		return
	
	roll_started.emit()
	print("🎲 Iniciando Fase de Fortuna...")

# -----------------------------------------------------------
# MÉTODO PÚBLICO: CONFIRMAR APUESTA Y TIRAR DADO
# -----------------------------------------------------------

## Ejecuta la apuesta: valida dinero, calcula bonificación, actualiza stats
func execute_roll(stat_id: String, amount_bet: int, dice_result: int) -> bool:
	# 1. Validar dinero
	if not GameState.spend_coins(amount_bet):
		return false
	
	# 2. Calcular bonificación: apuesta * resultado * multiplicador
	var bonus_amount: float = (amount_bet * dice_result) * bet_multiplier
	
	# 3. Aplicar al jugador
	if active_player.has_method("modificar_stat"):
		active_player.modificar_stat(stat_id, bonus_amount)
		GameState.record_stat_upgrade(stat_id, bonus_amount)
	else:
		push_error("FortuneRollManager: Player no tiene método 'modificar_stat'")
		return false
	
	# 4. Emitir señal de completitud
	roll_completed.emit(stat_id, amount_bet, dice_result, bonus_amount)
	print("✨ Apuesta completada: stat=%s, apuesta=%d, resultado_dado=%d, bonificación=%.1f" % [stat_id, amount_bet, dice_result, bonus_amount])
	
	return true

# -----------------------------------------------------------
# MÉTODO PÚBLICO: CANCELAR APUESTA
# -----------------------------------------------------------

## Cancela la fase de fortuna sin gastar monedas
func cancel_roll() -> void:
	print("❌ Fase de Fortuna cancelada")
	roll_completed.emit("", 0, 0, 0.0)
