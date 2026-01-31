extends CharacterBody2D

# -----------------------------------------------------------
# SEÑALES
# -----------------------------------------------------------
signal health_changed(new_health, max_health)

# -----------------------------------------------------------
# CONFIGURACIÓN DEL ARMA Y MOVIMIENTO
# -----------------------------------------------------------
const ESCENA_ESPADA = preload("res://espada_2.tscn")
const WEAPON_OFFSET_X: float = 3.5

@export_group("Movimiento")
@export var move_speed: float = 300.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.30

@export_group("Combate y Salud")
@export var max_health: float = 100.0
@export var attack_cooldown: float = 0.3
@export var invulnerability_time: float = 0.5 

# -----------------------------------------------------------
# ESTADO Y REFERENCIAS
# -----------------------------------------------------------
var current_health: float = 0.0
var is_dashing: bool = false
var dash_dir: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var attack_timer: float = 0.0
var invulnerable_timer: float = 0.0

var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: float = 0.0
var is_blocking: bool = false

@onready var punto_sujecion: Node2D = $SpritePBody
# Ruta según tu jerarquía: health_bar/CanvasLayer/HealthBar
@onready var health_bar = $HealthBar

var arma_actual: Node2D = null
var escala_original_x: float = 1.0

# -----------------------------------------------------------
# CICLO DE VIDA
# -----------------------------------------------------------
func _ready() -> void:
	# 1. IMPORTANTE: Añadir al grupo para que la ProgressBar te encuentre
	add_to_group("player")
	
	# 2. Inicializar salud
	current_health = max_health
	
	# 3. Equipamiento inicial
	equipar_arma_inicial()
	
	if punto_sujecion:
		escala_original_x = abs(punto_sujecion.scale.x)
		punto_sujecion.scale.x = escala_original_x
	
	# 4. Emitir estado inicial a la UI
	health_changed.emit(current_health, max_health)


func _physics_process(_delta: float) -> void:
	# Gestión de Timers (usamos _delta para evitar el warning)
	attack_timer = max(attack_timer - _delta, 0.0)
	invulnerable_timer = max(invulnerable_timer - _delta, 0.0)
	
	if is_dashing:
		dash_timer -= _delta
		velocity = dash_dir * dash_speed
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return
	
	velocity = Vector2.ZERO
	move_and_slide()

# -----------------------------------------------------------
# SISTEMA DE SALUD Y DAÑO
# -----------------------------------------------------------
func take_damage(amount: float) -> void:
	# No recibe daño si está muerto, es invulnerable o está en Dash
	if current_health <= 0 or invulnerable_timer > 0 or is_dashing:
		return
	
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	invulnerable_timer = invulnerability_time 
	
	# Emitir señal para que la ProgressBar se actualice sola
	health_changed.emit(current_health, max_health)
	
	# Feedback visual: Parpadeo rojo
	var flash = create_tween()
	flash.tween_property(punto_sujecion, "modulate", Color.RED, 0.1)
	flash.tween_property(punto_sujecion, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("¡Jugador eliminado!")
	set_physics_process(false) # Bloquea el movimiento
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

# SEÑAL DE LA HURTBOX (Conectar en el editor)
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Si el área enemiga tiene una propiedad 'damage', la usamos. Si no, 10 por defecto.
	if area.is_in_group("enemigos") or area.name.containsn("Hitbox"):
		var damage_to_deal = 10.0
		if "damage" in area:
			damage_to_deal = area.damage
		
		take_damage(damage_to_deal)

# -----------------------------------------------------------
# INPUT TOUCH Y ACCIONES
# -----------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			touch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			_check_for_gesture(event.position)
			
			# Detectar toque corto para ataque
			var dist = event.position.distance_to(touch_start_pos)
			var duration = (Time.get_ticks_msec() / 1000.0) - touch_start_time
			if dist < 40 and duration < 0.25:
				_attack()

func _check_for_gesture(end_pos: Vector2) -> void:
	var dir = end_pos - touch_start_pos
	if dir.length() > 80:
		_dash(dir.normalized())

func _dash(direction: Vector2) -> void:
	if is_dashing: return
	is_dashing = true
	dash_dir = direction
	dash_timer = dash_duration
	if dash_dir.x != 0:
		punto_sujecion.scale.x = escala_original_x * sign(dash_dir.x)

func _attack() -> void:
	if attack_timer > 0 or arma_actual == null: return
	attack_timer = attack_cooldown
	var animador = arma_actual.get_node_or_null("AnimationPlayer")
	if animador:
		animador.play("sword_swing")

func equipar_arma_inicial() -> void:
	if punto_sujecion == null: return
	if arma_actual != null: arma_actual.queue_free()
	
	var nueva_arma = ESCENA_ESPADA.instantiate()
	nueva_arma.position = Vector2(WEAPON_OFFSET_X, 0)
	punto_sujecion.add_child(nueva_arma)
	arma_actual = nueva_arma
