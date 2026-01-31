# Enemy.gd
extends CharacterBody2D

# -----------------------------------------------------------
# CONFIGURACIÓN FÍSICA Y RANGOS
# -----------------------------------------------------------
@export var move_speed: float = 100.0   # Velocidad de movimiento
@export var max_health: int = 50        # Salud máxima
@export var follow_range: float = 200.0 # Distancia a la que empieza a seguir al jugador
const ACCEL_RATE: float = 0.1           # Tasa de aceleración

# 🛑 CONFIGURACIÓN DE EFECTOS VISUALES
@export var damage_number_scene: PackedScene 
@export var vertical_offset: float = 10.0 

# -----------------------------------------------------------
# ESTADO Y REFERENCIAS
# -----------------------------------------------------------
var current_health: int
# Mantenemos la declaración de tipo pero la inicializamos vacía
var player: CharacterBody2D = null     

# VARIABLES PARA PATRULLAJE
var patrol_direction: Vector2 = Vector2.ZERO
var is_patrolling: bool = false

# REFERENCIAS DE NODOS
@onready var sprite_enemigo = $SpritePBody 
@onready var animation_player: AnimationPlayer = $SpritePBody/AnimationPlayer
@onready var patrol_timer: Timer = $PatrolTimer

var escala_original_x: float = 1.0 


func _ready():
	current_health = max_health
	
	# MODIFICACIÓN AQUÍ: Usamos "as CharacterBody2D" para evitar el error de asignación
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if player == null:
		push_error("ERROR: Player no encontrado. Asegúrate de que el Player esté en el grupo 'player'.")
	
	if sprite_enemigo == null:
		push_error("¡ERROR FATAL! No se encontró el nodo 'SpritePBody'.")
		return 

	escala_original_x = abs(sprite_enemigo.scale.x)
	sprite_enemigo.scale.x = escala_original_x 
	
	if patrol_timer == null:
		push_error("ERROR: El nodo 'PatrolTimer' no fue encontrado.")
		return
		
	patrol_timer.wait_time = 2.0 
	patrol_timer.one_shot = false
	
	# Verificamos conexión para evitar duplicados si reinicias la escena
	if not patrol_timer.timeout.is_connected(_on_patrol_timer_timeout):
		patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	
	patrol_timer.start()
	_on_patrol_timer_timeout()


# -----------------------------------------------------------
# CÁLCULO DE MOVIMIENTO Y FÍSICA (Sin cambios)
# -----------------------------------------------------------
func _physics_process(delta: float):
	var target_velocity: Vector2 = Vector2.ZERO
	var direction: Vector2 = Vector2.ZERO
	
	if sprite_enemigo == null: 
		return

	if player != null:
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= follow_range:
			is_patrolling = false
			patrol_timer.stop() 
			
			var target_position: Vector2 = player.global_position
			target_position.y -= vertical_offset 

			direction = global_position.direction_to(target_position)
			target_velocity = direction * move_speed
		else:
			is_patrolling = true
			if patrol_timer.is_stopped():
				patrol_timer.start()
			
			direction = patrol_direction
			target_velocity = direction * move_speed
		
		if direction.x != 0:
			sprite_enemigo.scale.x = escala_original_x * sign(direction.x)
	
	velocity = velocity.lerp(target_velocity, ACCEL_RATE)
	move_and_slide()


# -----------------------------------------------------------
# FUNCIÓN DE DAÑO Y LÓGICA VISUAL (Sin cambios)
# -----------------------------------------------------------
func take_damage(amount: int):
	current_health -= amount
	print(name, " golpeado. Salud restante: ", current_health)
	spawn_damage_number(amount)
	play_impact_animation()
	
	if current_health <= 0:
		die()

func spawn_damage_number(value: int):
	if damage_number_scene:
		var number = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(number)
		var x_spread = randf_range(-25, 25)
		var y_spread = randf_range(-10, 10)
		var spawn_pos = global_position + Vector2(x_spread, -30 + y_spread)
		
		if number.has_method("display_number"):
			number.display_number(value, spawn_pos)

func play_impact_animation():
	if animation_player.has_animation("bleed") and not animation_player.is_playing():
		animation_player.play("bleed")
	elif not animation_player.has_animation("bleed"):
		push_warning("La animación 'bleed' no existe en el AnimationPlayer.")

func _on_patrol_timer_timeout():
	if is_patrolling:
		patrol_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	
func die():
	print(name, " ha muerto!")
	queue_free()

# -----------------------------------------------------------
# SEÑALES DE COLISIÓN (Sin cambios)
# -----------------------------------------------------------
func _on_hurtbox_area_entered(area: Area2D):
	if area.has_method("get_damage"):
		var damage_amount = area.get_damage()
		take_damage(damage_amount)

func _on_area_entered(_area: Area2D) -> void:
	pass

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	pass
