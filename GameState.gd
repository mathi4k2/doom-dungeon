extends Node
## Singleton global para gestión de economía de monedas y estado del juego

# -----------------------------------------------------------
# SEÑALES
# -----------------------------------------------------------
signal coins_changed(new_amount: int)

# -----------------------------------------------------------
# VARIABLES DE ESTADO
# -----------------------------------------------------------
var coins: int = 0
var nivel_actual: int = 1
var total_damage_applied: float = 0.0
var total_health_applied: float = 0.0
var total_speed_applied: float = 0.0

# -----------------------------------------------------------
# MÉTODOS PÚBLICOS
# -----------------------------------------------------------

## Añade monedas al contador
func add_coins(amount: int) -> void:
	coins = max(0, coins + amount)
	coins_changed.emit(coins)
	print("💰 Monedas: ", coins)

## Gasta monedas (retorna true si hay suficientes)
func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		print("💸 Monedas gastadas: ", amount, " | Quedan: ", coins)
		return true
	else:
		print("❌ Monedas insuficientes. Tienes: ", coins, " necesitas: ", amount)
		return false

## Registra una mejora de stats en el historial
func record_stat_upgrade(stat_type: String, value: float) -> void:
	match stat_type:
		"daño":
			total_damage_applied += value
		"vida":
			total_health_applied += value
		"velocidad":
			total_speed_applied += value
