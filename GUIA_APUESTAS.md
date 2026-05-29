# GUÍA DE INTEGRACIÓN - Sistema de Sorteo con Apuestas

## 🎯 Resumen de Cambios

Se ha implementado un **sistema modular de apuestas con dados** que permite:
1. Recolectar monedas derrotando enemigos
2. Gastar monedas en la "Fase de Fortuna"
3. Tirar dados para modificar permanentemente los stats del jugador

## 📋 Archivos Creados/Modificados

### ✅ Creados
- **GameState.gd** → Autoload singleton for coin management
- **FortuneRollManager.gd** → Manager for dice roll logic
- **FortunePhaseUI.gd** → UI controller (connects dice, buttons, bets) 
- **fortune_phase.tscn** → New UI scene for betting phase

### ✏️ Modificados
- **project.godot** → Added GameState autoload
- **Player.gd** → Improved modificar_stat() with aliases
- **hurt_box.gd** (Enemy) → Now drops coins on death

---

## 🔌 PASO A PASO: CÓMO INTEGRAR EN TU PROYECTO

### 1️⃣ Registrar el Autoload
✅ **YA HECHO**: GameState está registrado en project.godot

Verifica:
```
[autoload]
GameState="*res://GameState.gd"
```

### 2️⃣ Añadir FortuneRollManager a Main.tscn
```
Main.tscn
├── TilemapLayers
├── Player
├── spawner_mage
└── FortuneRollManager (nuevo nodo → Script FortuneRollManager.gd)
```

**En el editor:**
1. Abre Main.tscn
2. Añade un nodo Node2D → Rename "FortuneRollManager"
3. Asigna el script FortuneRollManager.gd

### 3️⃣ Añadir FortunePhase a GameUI
```
GameUI.tscn
├── HUD_manager
│   └── HealthBar
└── Menus_container
    └── FortunePhase (instancia de fortune_phase.tscn)
```

**En el editor:**
1. Abre game_ui.tscn
2. Dentro de "Menus_container", añade: Scene → Instancia "fortune_phase.tscn"
3. La escena debe estar oculta por defecto (hide())

### 4️⃣ Mostrar/Ocultar FortunePhase
**Opción A**: Con tecla (temporal para testing)
```gdscript
# Añade a Main.gd o a un manager
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_F:
        if event.pressed:
            $GameUI/Menus_container/FortunePhase.show()
```

**Opción B**: Después de ciertos eventos (ej: fin de oleada)
```gdscript
# Cuando termina una oleada de spawner
fortune_phase_ui.show()
```

### 5️⃣ Conectar DiceRollerControl a FortunePhaseUI
**Manual en editor**:
1. Selecciona FortunePhase (la escena en game_ui.tscn)
2. Busca el nodo "DiceRollerControl" → Necesita ser configurado:
   - En Inspector → "dice_set": crea un DiceDef con D6 blanco
   - "interactive": true
3. Conecta la señal "roll_finished" a FortunePhaseUI._on_dice_roll_finished

---

## 🔄 FLUJO DE DATOS: Cómo Todo Se Conecta

```
Enemigo muere
    ↓
hurt_box.die() → GameState.add_coins(5-15)
    ↓
GameState.coins_changed.emit()
    ↓
FortunePhaseUI._on_coins_changed()
    ↓
[UI actualizada: "Monedas: X"]
    ↓
Jugador presiona botón "FASE DE FORTUNA"
    ↓
FortunePhase.show()
    ↓
Jugador selecciona:
  · Atributo (Daño, Salud, Velocidad)
  · Cantidad de apuesta (VScrollBar)
  · Tipo de dado (luego: D6, D12, D20)
    ↓
Presiona "TIRAR DADO"
    ↓
DiceRollerControl.roll() → emite roll_finished(resultado)
    ↓
FortunePhaseUI._on_dice_roll_finished(resultado)
    ↓
FortuneRollManager.execute_roll(stat, apuesta, resultado)
    ├─ GameState.spend_coins(apuesta) ✓
    ├─ Calcula: bonificación = apuesta × resultado × 1.5
    ├─ Player.modificar_stat(stat, bonificación)
    └─ Emite: roll_completed(stat, apuesta, resultado, bonificación)
    ↓
[Stats del jugador actualizados permanentemente]
    ↓
FortunePhaseUI._reset_ui() → Listo para nueva apuesta
```

---

## ⚙️ FÓRMULA DE BONIFICACIÓN

```gdscript
bonificación = (apuesta × resultado_dado) × multiplicador

# Ejemplos:
# Apuesta 10, Resultado D6=5, Mult=1.5 → 10×5×1.5 = +75 daño
# Apuesta 20, Resultado D6=6, Mult=1.5 → 20×6×1.5 = +180 salud
# Apuesta 5,  Resultado D6=1, Mult=1.5 → 5×1×1.5 = +7.5 velocidad
```

Puedes ajustar `bet_multiplier` en FortuneRollManager.gd

---

## 🛠️ MAPEO DE STATS SOPORTADOS

| Stat ID | Aliases | Efecto |
|---------|---------|--------|
| vida_max | salud, vida, health | Aumenta max_health |
| velocidad | speed | Aumenta speed_multiplier |
| ataque | daño, damage | Aumenta bonus_damage |

*(Se pueden agregar más stats fácilmente en Player.modificar_stat())*

---

## 📡 SIGNALS (Conexiones Usadas)

### GameState
```gdscript
coins_changed(new_amount: int)
```

### FortuneRollManager
```gdscript
roll_started
roll_completed(stat_id: String, amount_bet: int, roll_result: int, final_bonus: float)
```

### DiceRollerControl (addon)
```gdscript
roll_finished(value: int)
```

---

## 🎮 TESTING

1. **Verificar Autoload**:
   ```
   Abre Debug → Monitors
   Debería haber una variable global "GameState"
   ```

2. **Testing de flujo completo**:
   - Inicia el juego
   - Presiona ataque para matar enemigos
   - Verifica que las monedas se incrementen
   - Presiona F (o tu botón) para abrir FortunePhase
   - Selecciona Daño, apuesta 10, tira D6
   - Verifica que el daño del jugador aumentó

3. **Validar stats**:
   ```gdscript
   # En consola de Godot:
   print(player.current_health)
   print(player.bonus_damage)
   print(player.speed_multiplier)
   ```

---

## 🐛 COMMON ISSUES

### "FortuneRollManager not found"
- Asegúrate de que está en Main.tscn como nodo Node2D
- O el script lo creará dinámicamente si no existe

### "DiceRollerControl not connected"
- Verifica que fortune_phase.tscn tiene el nodo DiceRollerControl
- En el editor, configura "dice_set" con un D6

### "Coins no se restan"
- Verifica que GameState.spend_coins() retorna true
- Mensaje en consola dirá si hay monedas insuficientes

### "Stats no se actualizan"
- Verifica que Player está en grupo "player"
- Llamadas a modificar_stat() deben pasar stat_id válido

---

## 🚀 PRÓXIMAS MEJORAS (Roadmap)

1. **Sistema de evolución de dados**
   - D6 → D12 → D20 tras derrotar jefes
   - Cambiar fórmula de bonificación por tipo de dado

2. **Amuletos/Modificadores adicionales**
   - Multiplicador de bonificación por evento
   - Penalizaciones por fallar tirada

3. **Persistencia de stats**
   - Guardar stats del jugador entre escenas

4. **Animaciones visuales**
   - Efecto de monedas flotantes
   - Indicadores de stats actualizados
   - Sonidos

---

## 📞 SOPORTE RÁPIDO

**Script** que añade todo automáticamente **(OPCIONAL)**:
```gdscript
# auto_setup.gd - Ejecutar una sola vez
extends Node

func _ready() -> void:
    var main = get_tree().root.get_child(0)
    
    # 1. Crear FortuneRollManager si no existe
    if not main.has_node("FortuneRollManager"):
        var mgr = FortuneRollManager.new()
        mgr.name = "FortuneRollManager"
        main.add_child(mgr)
        print("✅ FortuneRollManager creado")
    
    # 2. Instanciar FortunePhase en GameUI
    var game_ui = main.get_node_or_null("GameUI")
    if game_ui and not game_ui.has_node("Menus_container/FortunePhase"):
        var fortune_scene = load("res://fortune_phase.tscn")
        var fortune_ui = fortune_scene.instantiate()
        game_ui.get_node("Menus_container").add_child(fortune_ui)
        fortune_ui.hide()
        print("✅ FortunePhase instanciada")
    
    queue_free()  # Ejecutar solo una vez
```

---

**¡Sistema listo para usar!** 🎲✨
