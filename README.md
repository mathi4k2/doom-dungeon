# Die or Dice (provisional) / DoomDungeon

Roguelike de acción 2D zenital en Godot donde la progresión se basa en apostar capacidades antes de cada combate mediante un sistema de dados.
El azar no decide si el combate es posible: decide qué tan bien puedes jugarlo.

> **Estado:** proyecto en desarrollo. Este README describe el concepto y el estado actual del prototipo.

## Concepto central

Antes de cada combate, el jugador realiza una apuesta de **capacidades temporales**, no de estadísticas base.
Estas apuestas determinan:

- Cuántos errores puede cometer.
- Qué herramientas tiene disponibles.
- Qué tan agresivo o conservador puede ser.

## Loop principal

1. Elegir dado (define estilo de riesgo).
2. Ver jefe del acto.
3. Comprar amuletos (preparación estratégica).
4. **Fase de Fortuna** (apuestas).
5. Combate (acción pura).
6. Derrotar jefe → evolución del dado / nuevas opciones.
7. Repetir con mayor dificultad.

## Fase de Fortuna (núcleo del diseño)

Antes de cada combate se apuesta por capacidades temporales.
En el prototipo ya existe la **pantalla del dado**: una escena de ventana donde se elige el dado a tirar y el **valor mínimo** que el jugador decide apostar.
El resultado de esa tirada alimenta las capacidades temporales del combate.

Las apuestas se aplican a:

- **Margen de error** (vida efectiva).
- **Ventanas de esquiva / parry**.
- **Recursos activos** (dash, habilidades).
- **Potencia ofensiva** (posible elemento).

### Sistema de umbral

- **Superar el umbral** → beneficio completo.
- **Quedar cerca** → beneficio degradado.
- **Fallar mucho** → desventaja activa.

Siempre hay resultado. Nunca “nada”.

## Sistema de dados

- **Dado de Hierro**: resultados estables, sin beneficios extremos, sin desventajas graves.
- **Dado de Cristal**: beneficios muy altos, desventajas activas peligrosas, puede romperse si se abusa.
- **Dado de Mercurio**: permite ajustar resultados gastando oro (recurso defensivo indirecto).

Los dados evolucionan al derrotar jefes.

## Combate

- Acción 2D zenital en tiempo real.
- No hay dados durante el combate: todo se resuelve por habilidad del jugador.
- Las apuestas determinan herramientas, tolerancia al error y opciones ofensivas.
- El combate siempre es jugable, incluso con malas apuestas.

## Sistema de armas

- Armas simples (patrón, alcance, velocidad).
- Sin builds propias ni elementos base.
- El arma es el medio, no el build.

Ejemplos: espada, lanza, martillo.

## Sistema elemental (opción B refinada)

Los elementos **no se eligen**: se reciben como recompensa por una buena apuesta ofensiva.

- 🔥 **Fuego** — Presión (daño continuo)
- ❄️ **Hielo** — Control (ralentiza)
- ⚡ **Electricidad** — Ruptura (stagger)

Reglas:

- Nunca más de un elemento por combate.
- No hay resistencias ni inmunidades.
- Los enemigos reaccionan de forma distinta a cada elemento.
- La asignación del elemento es predecible (arma, dado o jefe), no RNG puro.

## Enemigos y jefes

- Los enemigos no resisten elementos.
- Cambian su comportamiento según el daño recibido.
- El elemento define **cómo** se gana el combate, no **si** se gana.

**Boss Blinds**

- Modifican el sistema de apuestas.
- No anulan mecánicas ni UI.
- Obligan a adaptarse sin romper decisiones previas.

## Amuletos

- Pasivos con espacios limitados.
- Mejoran consistencia o mitigan castigos.
- Nunca garantizan éxito ni anulan malas tiradas.
- Sin trampas duras (no “1 → 20”).

## Identidad del juego

- El dado es el protagonista absoluto.
- El azar genera tensión, no frustración.
- La habilidad siempre importa.
- Cada run cuenta una historia distinta por cómo se apostó.

## Estado actual del prototipo

El prototipo actual ya incluye:

- Escena principal con jugador y spawner de enemigos.
- Pantalla del dado para seleccionar tipo de dado y valor mínimo apostado.
- Movimiento, dash y ataque por toque.
- Enemigos con patrullaje y persecución.

## Requisitos

- Godot 4.5.

## Cómo ejecutar

1. Abrir el proyecto en Godot.
2. Ejecutar la escena principal (`Main.tscn`).

## Roadmap corto (sugerido)

- Integrar el flujo completo de la Fase de Fortuna con las apuestas y sus efectos.
- Integrar amuletos y tienda previa a combate.
- Añadir un primer jefe y evolución de dado.
- Conectar elementos con apuestas ofensivas.
