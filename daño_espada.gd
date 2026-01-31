extends Area2D

# -----------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------
@export var damage: int = 10 

# -----------------------------------------------------------
# REFERENCIAS
# -----------------------------------------------------------
@onready var collision_shape = $Hitbox

# -----------------------------------------------------------
# FUNCIÓN DE CONSULTA DE DAÑO
# -----------------------------------------------------------
func get_damage() -> int:
	return damage

# -----------------------------------------------------------
# DETECCIÓN DE GOLPE (MODIFICADO A AREA_ENTERED)
# -----------------------------------------------------------
func _on_area_entered(area: Area2D) -> void:
	# 1. Solo procedemos si la colisión de la espada está activa
	if collision_shape.disabled:
		return

	# 2. Intentamos encontrar el método take_damage
	# Primero buscamos en el área (por si el script está en la Hurtbox)
	# Si no, buscamos en el padre (el nodo raíz del Enemigo)
	var target = area
	if not target.has_method("take_damage"):
		target = area.get_parent()

	# 3. Si el objetivo tiene la función, aplicamos daño
	if target.has_method("take_damage"):
		target.take_damage(damage)
		print("¡Impacto detectado en: ", target.name, " | Daño: ", damage)
		
		# Desactivamos la colisión para no golpear varias veces en un solo swing
		collision_shape.set_deferred("disabled", true)
	else:
		print("Se detectó un área (", area.name, "), pero no tiene método take_damage")

# Estas funciones estaban vacías en tu código original, 
# puedes borrarlas o dejarlas si las tienes conectadas por error.
func _on_body_entered(_body: Node2D):
	pass

func _on_area_2d_body_entered(_body: Node2D) -> void:
	pass
