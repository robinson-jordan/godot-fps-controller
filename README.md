# FPS Controller for Godot 4

A reusable first\-person character controller built on CharacterBody3D with smooth camera movement, configurable mouse look, jumping, and physics interpolation support.
The goal of this project is to provide a clean starting point to create an FPS style player character with a solid foundation.
The physics interpolation logic basically eliminates camera vibration when moving or rotating the camera.

## Features

- First\-person mouse look
- Configurable sensitivity and pitch limits
- WASD movement using camera\-relative input
- Jumping and gravity
- Smooth camera motion using physics interpolation
- Automatic mouse capture and release
- Decoupled yaw and pitch rotation system

## Requirements

- Godot 4.x
- Physics interpolation enabled

Enable physics interpolation in:

Project Settings → Physics → Common → Physics Interpolation

You may need to enable **Advanced Settings** to see this option.

## Node Structure

The controller expects the following hierarchy:

FPSController └── BodyPivot └── HeadPivot

BodyPivot handles horizontal rotation (yaw).

HeadPivot handles vertical rotation (pitch).

## Controls

| Action | Input |
| --- | --- |
| Move | WASD |
| Jump | Space |
| Look | Mouse |
| Release Mouse | Escape |
| Capture Mouse | Left Click |

## Input Map

The following actions must exist:

- move\_left
- move\_right
- move\_forward
- move\_backward
- jump
- ui\_cancel

## Usage

Attach FPSController.gd to a CharacterBody3D and create the required node hierarchy.

Configure movement and look settings in the inspector:

- Mouse Sensitivity
- Look Down Limit
- Look Up Limit
- Move Speed
- Jump Velocity

## Notes

The CharacterBody3D itself is never rotated.

Movement direction is calculated using the BodyPivot basis, allowing the controller to move relative to the player's view direction while keeping the physics body aligned with the world.

Camera smoothing is achieved using Godot's physics interpolation system and an interpolated top\-level pivot.

## License

MIT License

## Author

Jordan Robinson
