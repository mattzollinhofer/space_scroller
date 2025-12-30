# Product Roadmap

0. [x] Development Environment Setup — Install Godot 4.3, configure editor
   settings, set up Web export template, and initialize the Godot project
   structure. Apple Developer account deferred until iOS export phase. `S`

1. [x] Player Character — Create the player spacecraft with basic movement
   controls (touch input for up/down/left/right) and smooth scrolling camera
follow. `S`

2. [x] Side-Scrolling Environment — Implement auto-scrolling space background
   with parallax layers and basic ground/ceiling boundaries. `S`

3. [x] Obstacles System — Add static and moving obstacles (asteroids, space
   debris) with collision detection and player damage/death handling. `M`

4. [ ] Basic Enemies — Create 2-3 enemy types with simple movement patterns
   (stationary, horizontal patrol, following) and collision-based combat. `M`
   - bad aliens

5. [ ] Player Combat — Add player shooting mechanics with projectiles that can
   destroy enemies, including visual and audio feedback. `S`

6. [ ] Level Structure — Build a complete first level with defined start,
   obstacle sections, enemy placements, and level-end trigger. `M`

7. [ ] Boss Battle — Create an end-of-level boss with health bar, attack
   patterns, and victory condition that completes the level. `L`

8. [ ] Score System — Implement scoring for defeating enemies and completing
   levels, with persistent high score storage and display. `S`

9. [ ] Game UI — Build main menu, pause menu, game over screen, and HUD showing
   score, lives, and level progress. `M`

10. [ ] Additional Levels — Create 2-3 more levels with unique visual themes
    (different planets/areas of solar system), new obstacles, and escalating
difficulty. `L`

11. [ ] Additional Bosses — Design unique boss encounters for each additional
    level with distinct attack patterns and mechanics. `L`

12. [ ] Sidekick Helper — Add a good alien sidekick that can be unlocked as a
    bonus, providing assistance to the player (e.g., extra firepower, shield,
    or collecting pickups). `M`

13. [ ] Audio Integration — Add background music tracks, sound effects for
    actions (shooting, collecting, damage), and boss battle music. `M`

14. [ ] Polish and Juice — Add screen shake, particle effects, animations, and
    visual feedback to make gameplay feel responsive and satisfying. `M`

15. [ ] Web Export — Configure and test HTML5 build with keyboard/mouse fallback
    controls and web-optimized performance. `S`

16. [ ] iOS Export — Configure and test iOS/iPad build with proper touch
    controls, App Store assets, Apple Developer account, and performance
    optimization. `M`

> Notes
>
> - Item 0 is the prerequisite setup before any development begins
> - Order reflects technical dependencies (player before enemies, levels before
>   bosses)
> - Each item represents a complete, testable feature slice
> - Items 1-9 form the MVP with one complete level
> - Items 10-14 expand content and polish
> - Item 15 releases to Web
> - Item 16 adds iOS/App Store (requires Apple Developer account)
