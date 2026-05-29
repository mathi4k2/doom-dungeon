extends CharacterBody2D

# -----------------------------------------------------------
# SEÑALES
# -----------------------------------------------------------
signal health_changed(new_health, max_health)
signal stats_updated # Nueva señal para avisar a la UI si los stats cambian

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

# --- NUEVOS ATRIBUTOS PARA APUESTAS ---
var bonus_damage: float = 0.0      # Daño extra plano
var speed_multiplier: float = 1.0  # Multiplicador de velocidad
# --------------------------------------

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
@onready var health_bar = $HealthBar

var arma_actual: Node2D = null
var escala_original_x: float = 1.0

# -----------------------------------------------------------
# CICLO DE VIDA
# -----------------------------------------------------------
func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	equipar_arma_inicial()
	
	if punto_sujecion:
		escala_original_x = abs(punto_sujecion.scale.x)
	
	health_changed.emit(current_health, max_health)

func _physics_process(_delta: float) -> void:
	attack_timer = max(attack_timer - _delta, 0.0)
	invulnerable_timer = max(invulnerable_timer - _delta, 0.0)
	
	if is_dashing:
		dash_timer -= _delta
		# Aplicamos el multiplicador de velocidad también al dash si quieres
		velocity = dash_dir * (dash_speed * speed_multiplier)
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return
	
	velocity = Vector2.ZERO
	move_and_slide()

# -----------------------------------------------------------
# SISTEMA DE ACTUALIZACIÓN DE STATS (PARA APUESTAS)
# -----------------------------------------------------------

## Función central para recibir mejoras o penalizaciones desde FortuneRollManager
func modificar_stat(stat_id: String, cantidad: float) -> void:
	# Normalizar aliases de stats para evitar confusiones
	var stat_normalizado = stat_id.to_lower().strip_edges()
	
	match stat_normalizado:
		"vida_max", "salud", "vida", "health":
			max_health = max(10, max_health + cantidad)
			if cantidad > 0:
				current_health = clamp(current_health + cantidad, 0, max_health)
			else:
				current_health = min(current_health, max_health)
			health_changed.emit(current_health, max_health)
			print("❤️  Vida Máxima: %.1f → %.1f" % [max_health - cantidad, max_health])
			
		"velocidad", "speed":
			# Modifica el multiplicador (si es 50, suma 0.5x = 50%)
			var cambio = cantidad / 100.0
			speed_multiplier = max(0.5, speed_multiplier + cambio)
			print("⚡ Velocidad: %.2fx" % speed_multiplier)
			
		"ataque", "daño", "damage":
			bonus_damage = max(0, bonus_damage + cantidad)
			print("⚔️  Daño: +%.1f (total: %.1f)" % [cantidad, bonus_damage])
		
		_:
			push_warning("Stat desconocido: ", stat_id)
			return

	stats_updated.emit()

# -----------------------------------------------------------
# SISTEMA DE SALUD Y DAÑO
# -----------------------------------------------------------
func take_damage(amount: float) -> void:
	if current_health <= 0 or invulnerable_timer > 0 or is_dashing:
		return
	
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	invulnerable_timer = invulnerability_time 
	
	health_changed.emit(current_health, max_health)
	
	var flash = create_tween()
	flash.tween_property(punto_sujecion, "modulate", Color.RED, 0.1)
	flash.tween_property(punto_sujecion, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		die()

func die() -> void:
	set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigos") or area.name.containsn("Hitbox"):
		var damage_to_deal = 10.0
		if "damage" in area:
			damage_to_deal = area.damage
		take_damage(damage_to_deal)

# -----------------------------------------------------------
# INPUT Y ATAQUE (Modificado para usar bonus_damage)
# -----------------------------------------------------------
func _attack() -> void:
	if attack_timer > 0 or arma_actual == null: return
	attack_timer = attack_cooldown
	
	# Si tu arma tiene una propiedad de daño, aquí se la pasamos
	if "damage" in arma_actual:
		# Daño base del arma + nuestro bono de apuesta
		var daño_total = arma_actual.base_damage + bonus_damage
		# Aquí podrías aplicar el daño al área de ataque
	
	var animador = arma_actual.get_node_or_null("AnimationPlayer")
	if animador:
		animador.play("sword_swing")

# --- Resto de funciones (Dash, Equipar) se mantienen igual ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			touch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			_check_for_gesture(event.position)
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

func equipar_arma_inicial() -> void:
	if punto_sujecion == null: return
	if arma_actual != null: arma_actual.queue_free()
	
	var nueva_arma = ESCENA_ESPADA.instantiate()
	nueva_arma.position = Vector2(WEAPON_OFFSET_X, 0)
	punto_sujecion.add_child(nueva_arma)
	arma_actual = nueva_arma
