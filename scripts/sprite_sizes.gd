class_name SpriteSizes
## Central source of truth for all sprite scale values.
## Scene files (.tscn) cannot reference these constants directly,
## but scripts should use these values for consistency.

# Player & Characters
const PLAYER = Vector2(0.75, 0.75)
const SIDEKICK = Vector2(0.5, 0.5)

# Standard Enemies (patrol, shooting, stationary, charger)
const ENEMY_STANDARD = Vector2(0.75, 0.75)
# Large Enemies (garlic, ghost_eye)
const ENEMY_LARGE = Vector2(1.125, 1.125)

# Boss (base scene scale - JSON config multiplier applied on top)
const BOSS_BASE = Vector2(0.375, 0.375)

# Projectiles
const PROJECTILE_PLAYER = Vector2(0.5, 0.5)
const PROJECTILE_ENEMY = Vector2(0.625, 0.625)
const PROJECTILE_BOSS = Vector2(0.625, 0.625)

# Pickups
const PICKUP_STANDARD = Vector2(0.75, 0.75)

# Asteroids
const ASTEROID_SMALL = Vector2(0.5, 0.5)
const ASTEROID_REGULAR = Vector2(0.625, 0.625)
const ASTEROID_LARGE = Vector2(0.875, 0.875)

# Effects
const EXPLOSION_ENEMY = Vector2(0.5, 0.5)
const EXPLOSION_ASTEROID_IMPACT = Vector2(0.25, 0.25)
const HIT_FLASH_MULTIPLIER: float = 1.3
const BOSS_HIT_FLASH_MULTIPLIER: float = 1.2
