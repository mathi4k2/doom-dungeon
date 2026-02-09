extends VScrollBar

# Referencia al Label hijo
@onready var info_label = $Label

func _ready():
	# 1. Configuración inicial
	self.max_value = 6
	self.step = 1.0   # Incrementos de 1 en 1
	self.page = 0.0   # IMPORTANTE: 0 para que el valor máximo sea alcanzable
	
	# 2. Conectamos la señal de cambio de valor a nuestra propia función
	# 'value_changed' se emite automáticamente al mover la barra
	self.value_changed.connect(_on_value_changed)
	
	# Actualización inicial del texto
	actualizar_texto()

# --- Funciones para que los botones llamen ---
# Puedes conectar la señal 'pressed' de tus botones a estas funciones

func _on_d6_pressed():
	definir_maximo(6)

func _on_d12_pressed():
	definir_maximo(12)

func _on_d20_pressed():
	definir_maximo(20)

# --- Lógica interna ---

func definir_maximo(nuevo_max: float):
	self.max_value = nuevo_max
	# Si el valor actual quedó por encima del nuevo máximo, Godot lo ajusta solo,
	# pero llamamos a la actualización para refrescar el Label visualmente.
	actualizar_texto()

func _on_value_changed(_valor: float):
	actualizar_texto()

func actualizar_texto():
	# Formateamos el texto como "Actual / Máximo"
	# Usamos int() para que no aparezcan decimales (ej: "3 / 6" en vez de "3.0 / 6.0")
	info_label.text = str(int(self.value)) + " / " + str(int(self.max_value))
