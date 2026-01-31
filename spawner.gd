extends Node2D

# 1. Variable que se enlaza con la escena del enemigo en el Inspector
# Asegúrate de arrastrar 'Enemigo.tscn' a esta casilla en el editor.
@export var escena_enemigo: PackedScene

func _ready():
	# Esta función se llama una vez que el Spawner está listo.
	# Usamos _ready() para iniciar la generación.
	print("El Spawner ha iniciado. Generando enemigos...")
	spawnear_grupo_enemigos(5)


# Función para generar una cantidad específica de enemigos
func spawnear_grupo_enemigos(cantidad: int):
	# Iteramos la cantidad de veces que queremos generar
	for i in range(cantidad):
		# A. Crear la copia (la instancia) del enemigo
		var nuevo_enemigo = escena_enemigo.instantiate()
		
		# B. Darle una posición aleatoria para que no se apilen
		# Genera un offset aleatorio de -100 a 100 píxeles.
		var offset_random = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		nuevo_enemigo.position = self.position + offset_random
		
		# C. Agregar el enemigo al árbol de escenas usando call_deferred.
		# Esto soluciona el error "Parent node is busy".
		# Agregamos el enemigo al padre del Spawner (es decir, al Nivel).
		get_parent().call_deferred("add_child", nuevo_enemigo)
		
	print("Se generaron ", cantidad, " enemigos con éxito.")
