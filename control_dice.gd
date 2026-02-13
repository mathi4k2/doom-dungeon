extends Control

@onready var roller: DiceRollerControl = $DiceRollerControl
@onready var scroll_bar: VScrollBar = $VScrollBar

@onready var btn_fuerza: Button = $VBoxContainer2/Button
@onready var btn_salud: Button = $VBoxContainer2/Button2
@onready var btn_stamina: Button = $VBoxContainer2/Button3

# Variables de prerrequisitos
var dado_seleccionado: bool = false
var atributo_seleccionado: bool = false
var scroll_definido: bool = false

func _ready():
	# 1. Definimos el dado como BLANCO desde el segundo 1 para evitar cambios de color
	_select_dice("D6")
	dado_seleccionado = false # Lo reseteamos a false porque el usuario aún no lo "eligió"
	
	# 2. Bloqueamos interacción
	roller.interactive = false
	
	# 3. Conexiones seguras
	if not scroll_bar.value_changed.is_connected(_on_scroll_bar_value_changed):
		scroll_bar.value_changed.connect(_on_scroll_bar_value_changed)
	
	if roller.has_signal("roll_finished"):
		if not roller.roll_finished.is_connected(_on_dice_roll_finished):
			roller.roll_finished.connect(_on_dice_roll_finished)
	
	btn_fuerza.pressed.connect(_on_fuerza_pressed)
	btn_salud.pressed.connect(_on_salud_pressed)
	btn_stamina.pressed.connect(_on_stamina_pressed)

# --- Validación ---

func _intentar_activar_lanzamiento():
	if dado_seleccionado and atributo_seleccionado and scroll_definido:
		roller.interactive = true
		print("¡Todo listo! Dado interactivo.")
	else:
		roller.interactive = false

# --- Receptores ---

func _on_scroll_bar_value_changed(value: float):
	scroll_definido = true
	print("Vscrollbar: ", int(value))
	_intentar_activar_lanzamiento()

func _on_dice_roll_finished(result: Variant):
	print("Resultado del dado: ", result)

# --- Botones de Atributo ---

func _on_fuerza_pressed():
	atributo_seleccionado = true
	print("Botón presionado: Fuerza")
	_intentar_activar_lanzamiento()

func _on_salud_pressed():
	atributo_seleccionado = true
	print("Botón presionado: Salud")
	_intentar_activar_lanzamiento()

func _on_stamina_pressed():
	atributo_seleccionado = true
	print("Botón presionado: Stamina")
	_intentar_activar_lanzamiento()

# --- Selección de Dados ---

func _on_d6_pressed():
	_select_dice("D6")

func _on_d12_pressed():
	_select_dice("D12")

func _on_d20_pressed():
	_select_dice("D20")

func _select_dice(type: String):
	dado_seleccionado = true
	var def := DiceDef.new()
	def.name = type
	def.color = Color.WHITE # <--- Siempre blanco
	def.shape = DiceShape.new(type)
	
	if "dice_set" in roller:
		roller.dice_set = [def]
	else:
		var interno = roller.find_child("DiceRoller", true, false)
		if interno:
			interno.dice_set = [def]
			
	_intentar_activar_lanzamiento()
