# Die or Dice

**Die or Dice** es un juego móvil 2D horizontal desarrollado en Godot 4 con mecánicas de acción roguelike y progresión basada en apuestas de dados. El proyecto parte de una idea clara: el combate se resuelve con habilidad, mientras que la fortuna define la potencia y la estrategia del jugador en cada run.

> Anteriormente el proyecto se conocía como **Exponential Reaping**. En esta etapa actual, el núcleo de jugabilidad ya está conectado con el sistema de fortuna, las oleadas de enemigos y la progresión de stats.

---

## 1. Título e Introducción

### Qué es Die or Dice

Die or Dice combina tres capas de diseño:

- **Acción 2D horizontal** en tiempo real.
- **Roguelike de progresión** donde cada oleada mejora la capacidad del jugador.
- **Sistema de apuestas de dados** que convierte el riesgo en una mecánica de build permanente.

La intención del proyecto es sencilla: matar enemigos, ganar monedas, entrar en la fase de fortuna, mejorar stats y repetir con olas más difíciles.

### Estado actual del proyecto

- Prototipo funcional en Godot 4 + GDScript.
- Sistema de oleadas modular y configurable.
- Fase de fortuna desacoplada mediante señales.
- Progresión de stats aplicada al jugador a través de apuestas.

---

## 2. Core Loop (Bucle de Juego)

El ciclo principal del juego funciona así:

1. **Matar enemigos** para obtener monedas y avanzar en la oleada.
2. **Conseguir monedas** mediante combate y supervivencia.
3. **Entrar en la Fase de Fortuna** para apostar parte de ese progreso.
4. **Mejorar stats permanentemente** (daño, vida o velocidad).
5. **Enfrentar olas más difíciles** con el jugador ya más fuerte.

Este bucle crea una progresión directa: el jugador no solo sobrevive, sino que transforma cada combate en una inversión de riesgo y recompensa.

---

## 3. Arquitectura Técnica (Godot 4 & GDScript)

La base del proyecto está organizada de forma modular para facilitar el crecimiento. A continuación, la estructura técnica actual del juego.

### GameState (Autoload / Singleton)

El archivo `GameState.gd` actúa como estado global del juego.

Funciones principales:

- Gestiona las monedas del jugador (`coins`).
- Lleva el nivel actual (`nivel_actual`).
- Registra la progresión acumulada de stats (`total_damage_applied`, `total_health_applied`, `total_speed_applied`).

Esto evita que la lógica de progreso dependa de rutas rígidas entre escenas.

### Main / Nivel Raíz

El controlador principal en `Main.gd` se encarga del flujo del nivel:

- Conecta la señal de oleada completada del `Spawner`.
- Instancia y coordina la UI de Fortuna.
- Pausa el juego al entrar en la fase de apuesta.
- Reinicia la siguiente oleada cuando la fase termina.

La idea es que `Main` actúe como orquestador del loop, no como contenedor de lógica específica del combate.

### Spawner (Data-Driven)

El sistema de oleadas está implementado en `spawner.gd` y está pensado para ser escalable:

- Lee la configuración del nivel desde un `Array[Dictionary]`.
- Ajusta `enemigos_por_ola`, `costo_apuesta` y enemigos posibles según el nivel.
- Genera oleadas automáticamente y emite una señal cuando una fase termina.

Esto permite añadir nuevos niveles sin reescribir la lógica de spawning.

### Sistema de Fortuna (Desacoplado)

La Fase de Fortuna está separada en dos capas:

- `FortuneRollManager.gd`: ejecuta la lógica de apuestas y aplica mejoras al jugador.
- `FortunePhaseUI.gd`: muestra la interfaz y dispara la tirada.

La comunicación se hace mediante señales (`roll_completed`, `fortune_finished`) y no depende de rutas duras entre nodos.

---

## 4. Tabla de Stats Soportados

Actualmente la progresión de apuestas está conectada a estos tres modificadores:

| Stat | Variable principal | Efecto actual | Fuente de aplicación |
|---|---|---|---|
| Daño | `bonus_damage` | Aumenta el daño adicional del jugador | `Player.gd` + `FortuneRollManager.gd` |
| Salud | `max_health` / `current_health` | Aumenta la vida máxima y ajusta la vida actual | `Player.gd` |
| Velocidad | `speed_multiplier` | Modifica la velocidad de movimiento y dash | `Player.gd` |

### Nota técnica

La función `modificar_stat()` en `Player.gd` normaliza los aliases (`daño`, `salud`, `velocidad`) y aplica el cambio real al personaje.

---

## 5. Guía de Expansión (Cómo crear un nuevo nivel)

Agregar un nuevo nivel es simple porque la configuración vive en el `Spawner` como datos.

### Ejemplo de configuración de nivel

```gdscript
@export var configuracion_niveles: Array[Dictionary] = [
    {"enemigos_por_ola": 3, "costo_apuesta": 10, "enemigos_posibles": [preload("res://enemy.tscn")]},
    {"enemigos_por_ola": 5, "costo_apuesta": 15, "enemigos_posibles": [preload("res://enemy.tscn")]},
    {"enemigos_por_ola": 7, "costo_apuesta": 20, "enemigos_posibles": [preload("res://enemy.tscn"), preload("res://spawner_mage.tscn")]},
]
```

### Qué ocurre al añadir un nivel

- `Main.gd` incrementa `GameState.nivel_actual` cuando termina una oleada.
- `Spawner.aplicar_configuracion_nivel()` carga la configuración del siguiente índice.
- Las nuevas olas ya heredan el sistema sin tocar la lógica principal.

Este diseño hace que el proyecto sea fácil de escalar: nuevos enemigos, nuevos costes o nuevas dificultades pueden añadirse como datos, no como código duplicado.

---

## Cómo ejecutar el proyecto

1. Abre la carpeta del proyecto en Godot 4.
2. Ejecuta la escena principal `Main.tscn`.
3. Revisa la lógica del flujo en `Main.gd`, `spawner.gd` y `FortuneRollManager.gd`.

---

## Resumen ejecutivo

Die or Dice ya no es solo una idea conceptual: su arquitectura actual permite:

- generar oleadas de forma modular,
- aplicar mejoras permanentes a través de apuestas,
- separar la UI de la lógica de progreso,
- y escalar el contenido por niveles con cambios pequeños.

Ese es el punto fuerte del proyecto en esta etapa: una base técnica limpia para convertir una idea de roguelike de dados en un sistema jugable, medible y extensible.
