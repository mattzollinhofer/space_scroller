# Boss Battle Feature - Initial Idea

## Description

Create an end-of-level boss with health bar, attack patterns, and victory condition that completes the level.

## Context

This is roadmap item 7. The boss battle hooks into the `level_completed` signal from the Level Structure feature (item 6) that was just implemented. When the player reaches 100% progress, instead of showing "Level Complete" immediately, the boss should appear.

## Existing Assets

Boss sprites already exist in the codebase:
- `res://assets/sprites/boss-1.png`
- `res://assets/sprites/boss-2.png`
