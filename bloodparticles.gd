# BloodParticles.gd
# Este script extiende el nodo raíz (Node2D) de la escena de partículas
extends Node2D

# --------------------------------------------------------------------------
# @onready NO PUEDE ENCONTRAR UN NODO SI EL NOMBRE DEL NODO ESTÁ MAL ESCRITO
# O SI EL NODO PADRE NO TIENE ESE HIJO.
# ¡Asegúrate de que los nombres de tus nodos hijos coincidan EXACTAMENTE!
# --------------------------------------------------------------------------
@onready var particles: GpuParticles2D = $ImpactParticles
@onready var timer: Timer = $Timer

func _ready():
	# 1. Conecta la señal 'finished' de las partículas (cuando dejan de emitir)
	particles.finished.connect(_on_particles_finished)
	
	# 2. Configura el temporizador para que elimine el nodo DESPUÉS de que las partículas mueran.
	timer.wait_time = particles.lifetime + 0.1 # Damos un pequeño extra de tiempo
	timer.one_shot = true
	
	# 3. Importante: Asegúrate de que las partículas NO estén emitiendo al inicio
	particles.emitting = false 

func play():
	# Esta función se llama desde el script del enemigo (Enemy.gd)
	particles.emitting = true
	timer.start()

# Cuando las partículas terminan su emisión, el temporizador sigue contando hasta queue_free()
func _on_particles_finished():
	pass 

# Cuando el temporizador termina (después de que el efecto ha pasado)
func _on_timer_timeout():
	queue_free() # Elimina la escena de partículas del juego
