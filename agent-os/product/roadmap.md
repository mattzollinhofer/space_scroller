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

4. [x] Basic Enemies — Create 2-3 enemy types with simple movement patterns
   (stationary, horizontal patrol, following) and collision-based combat. `M`
   - bad aliens

5. [x] Player Combat — Add player shooting mechanics with projectiles that can
   destroy enemies, including visual and audio feedback. `S`

6. [x] Level Structure — Build a complete first level with defined start,
   obstacle sections, enemy placements, and level-end trigger. `M`

7. [x] Boss Battle — Create an end-of-level boss with health bar, attack
   patterns, and victory condition that completes the level. `L`

8. [x] Score System — Implement scoring for defeating enemies and completing
   levels, with persistent high score storage and display. `S`

9. [x] Game UI — Build main menu, pause menu, game over screen, and HUD showing
   score, lives, and level progress. `M`

10. [x] Sidekick Helper — Add a good alien sidekick that can be unlocked as a
    bonus, providing assistance to the player (e.g., extra firepower, shield,
    or collecting pickups). `M`

11. [x] Web Export — Configure and test HTML5 build with keyboard/mouse fallback
    controls and web-optimized performance. `S`

12. [x] GitHub Pages Hosting — Deploy the web export to GitHub Pages for public
    play. Use localStorage for personal high score persistence. Future: upgrade
    to Firebase for global leaderboards. `S`

12.5. [x] Additional level through length and enemy difficulty. More enemies,
      different enemies. Shooting enemy. Longer time span. Different boss.

13. [x] Additional Levels — Create 2-3 more levels with unique visual themes
    (different planets/areas of solar system), new obstacles, and escalating
    difficulty. `L`

14. [ ] Additional Bosses — Design unique boss encounters for each additional
    level with distinct attack patterns and mechanics. `L`

15. [x] Audio Integration — Add background music tracks, sound effects for
    actions (shooting, collecting, damage), and boss battle music. `M`

16. [x] Polish and Juice — Add screen shake, particle effects, animations, and
    visual feedback to make gameplay feel responsive and satisfying. `M`

17. [ ] iOS Export — Configure and test iOS/iPad build with proper touch
    controls, App Store assets, Apple Developer account, and performance
    optimization. `M`

18. [ ] Audio Polish — Replace placeholder sine-wave audio with production-quality
    music and sound effects. Use AI generation tools (Suno, ElevenLabs) with
    prompts documented in `agent-os/product/audio-generation-prompts.md`. `S`

19. [ ]  Add new level, level 4. This will mostly use the same approach as all previous
    levels. A few notes:
    a. theme is pepperoni pizza
    b. there is a new boss: pepperoni pizza boss
       i. the boss has a custom attack sprite
       ii. the boss has a special attack sequence: 1) enter 2) three pronged
pepperoni attack 3) complete circle movement around the "arena" 4) repeat attack
    c. there are custom images/sprites to be used
    d. there is a new enemy called garlic man. he has a custom sprite and
"pizza-attack" sprite. he moves with the zig-zag pattern, but a little faster
than normal. he has 3 health.

20. [x]  Add a new level, level 5. This will mostly use the same approach as all previous
    levels. A few notes:
    a. theme is ghost
    b. there is a new boss: ghost monster boss
        i. the boss has a custom attack sprite
        ii.the boss has a custom attack sequence: 1) enter. 2) wall attack (ask
for description) 3) square move around arena 4) repeat attack
        iii. there is a special enemy called ghost eye. same zig-zag pattern.
3 health. moves a bit faster than other enemeies. 5-10 of these special enemies
per level

21. [ ] Add a new level, level 6. This will mostly use the same approach as all
    previous levels. A few notes:
    a. theme is rainbow colored jelly
    b. there is a new boss: jelly monster
       i. the boss has a custom attack sprite (weapon-jelly)
       ii. the boss has a custom attack sequence: 1) enter 2) up and down while
shooting 3) grow 4x larger then shrink to normal size 4) rapid jelly attack
5) repeat
    c. there is a new enemy called jelly snail. add to spawn sequence. slow
zig-zag movement. 5 health. slow shooting. 10ish (+/- 3) per level

22. [ ] Missile Power-Up — Add a collectible power-up that strengthens the
    player's missiles. When collected, missile damage increases from 1 to 2. `S`

> Notes
>
> - Item 0 is the prerequisite setup before any development begins
> - Order reflects technical dependencies (player before enemies, levels before
>   bosses)
> - Each item represents a complete, testable feature slice
> - Items 1-9 form the MVP with one complete level
> - Items 10, 13-16 expand content and polish
> - Items 11-12 release to Web
> - Item 17 adds iOS/App Store (requires Apple Developer account)
