# Additional Bosses Spec Initialization

## Roadmap Item
14. Additional Bosses - Design unique boss encounters for each additional level with distinct attack patterns and mechanics. `L`

## Initial Description
From the product roadmap: "Design unique boss encounters for each additional level with distinct attack patterns and mechanics."

## Context from Codebase Analysis

### Current State
- **3 levels exist**: Level 1, Level 2, and Level 3 (JSON-driven)
- **1 boss class exists**: `boss.gd` with configurable attacks via level JSON
- **4 boss sprites exist**: boss-1.png through boss-4.png (suggesting plans for more levels)
- **Current boss has 3 attack patterns**:
  - Attack 0: Horizontal barrage (5-7 projectile spread)
  - Attack 1: Vertical sweep (moves up/down while firing single projectiles)
  - Attack 2: Charge attack (rushes toward player then retreats)

### How Bosses Are Currently Differentiated
Each level's JSON metadata configures the single Boss class differently:
- **Level 1**: health=10, scale=5, attacks=[0], cooldown=1.5s
- **Level 2**: health=13, scale=6, attacks=[0,1], cooldown=1.3s
- **Level 3**: health=16, scale=8, attacks=[0,1,2], cooldown=1.1s

### Key System Details
- Boss spawns when level reaches 100% progress
- Entrance animation from right side to battle position (right third of screen)
- Screen scrolling stops during boss fight (arena mode)
- Player respawns at boss if defeated during boss fight
- Boss has health bar UI, damage flash, screen shake on defeat
