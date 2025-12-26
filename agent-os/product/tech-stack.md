# Tech Stack

## Game Engine & Language

- **Game Engine:** Godot 4.3 (latest stable)
- **Primary Language:** GDScript
- **Secondary Language:** C# (available if needed for performance-critical systems)
- **Project Type:** 2D Mobile Game

## Development Environment

- **Scene Editor:** Godot Editor (visual scene design, animation, asset management)
- **Code Editor:** Claude Code (GDScript editing and development)
- **Version Control:** Git

## Target Platforms

### Primary Platforms

- **iOS:** iPad (touch-optimized)
- **Web:** HTML5 (browser-based)

### Export Configuration

- **iOS Export:** Godot iOS export templates
- **Web Export:** Godot HTML5 export templates

## Asset Pipeline

### Graphics

- **Sprite Format:** PNG (primary), SVG (scalable assets)
- **Style:** Simple 2D graphics, kid-friendly visuals
- **Tileset System:** Godot TileMap for level construction

### Audio

- **Music Format:** OGG Vorbis (background music, boss themes)
- **Sound Effects Format:** WAV (short audio clips, actions, feedback)

## Godot-Specific Systems

### Core Systems

- **Physics:** Godot 2D physics engine (CharacterBody2D, Area2D, collision shapes)
- **Animation:** AnimationPlayer, AnimatedSprite2D
- **UI:** Control nodes, CanvasLayer for HUD
- **Input:** InputMap with touch and keyboard/mouse actions

### Scene Structure

- **Autoloads:** Global scripts for game state, score management, audio
- **Scene Inheritance:** Base scenes for enemies, projectiles, obstacles
- **Signals:** Event-driven communication between nodes

## Data Storage

- **Save System:** Godot ConfigFile or JSON for high scores and settings
- **Platform Storage:** User data directory (user://)
