# Armageddon

A space shooter game where you control a rocket and defend against incoming asteroids.

## Requirements

- LÖVE 11.4 or later (https://love2d.org/)

## How to Run

### On macOS

1. Install LÖVE from https://love2d.org/
2. Double click the game folder
   
   OR
   
3. From terminal:
   ```bash
   love /path/to/game/folder
   ```

### Project Structure

- `main.lua`: Main game entry point
- `conf.lua`: Game configuration
- `assets/`: Game assets (images, sounds, etc.)

## Controls

- UP ARROW: Thrust forward
- LEFT/RIGHT ARROWS: Rotate ship
- SPACE: Shoot
- ESC: Quit game
- R: Restart game (after game over)

## Gameplay

- Control your rocket and shoot incoming asteroids
- Each destroyed asteroid gives you 100 points
- You have 3 lives
- Game ends when you run out of lives
- Asteroids spawn from all sides of the screen

## Development

This game is built using LÖVE (Love2D), a free 2D game framework based on Lua.