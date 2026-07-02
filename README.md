# Roblox Tactical RPG Movement System #

A modular **Point & Click movement framework** developed in **Luau** for Roblox Studio, inspired by tactical RPGs such as **Baldur's Gate 3** and **Divinity: Original Sin 2**.

The project was designed as the foundation of a turn-based combat system, where movement can later consume Action Points (AP), support abilities, and integrate with AI-controlled units.

Rather than focusing only on character movement, the goal was to create a reusable architecture that separates camera control, player input and navigation into independent systems.

---

# Features

* Point & Click movement
* Roblox PathfindingService integration
* Dynamic waypoint traversal
* Smooth braking near destination
* Interruptible movement
* Modular movement controller
* Tactical camera system
* Follow Camera / Free Camera modes
* Mouse-controlled camera rotation
* Zoom system
* Combat movement lock
* Visual click feedback
* Future-ready Action Point architecture

---

# Project Structure

```text
StarterCharacterScripts
├── CameraSystem.lua
└── Movement.lua

ReplicatedStorage
└── Modules
    └── MovementController.lua
```

---

# Camera System

The camera was built from scratch using a Scriptable Camera instead of Roblox's default camera controller.

Current features include:

* Smooth camera interpolation (Lerp)
* Adjustable zoom
* Mouse rotation
* Q / E camera rotation
* Follow Character mode
* Free Camera mode
* WASD free camera movement
* Configurable movement radius around the player

The camera controller is completely independent from the movement system, allowing both systems to evolve without creating unnecessary dependencies.

---

# Movement Controller

The MovementController module centralizes every navigation-related operation.

Its responsibilities include:

* Path generation using PathfindingService
* Waypoint traversal
* Automatic jump handling
* Movement interruption
* Speed adjustment near destination
* Future support for skill movement

Each movement request generates an internal Movement ID.

If another destination is selected before the current movement finishes, the previous navigation is cancelled immediately, preventing multiple movement loops from running simultaneously.

---

# Dynamic Braking

Instead of instantly stopping when reaching the final waypoint, the controller gradually reduces the Humanoid's WalkSpeed based on the remaining distance.

This creates smoother character movement while avoiding abrupt stops.

Different braking configurations already exist for future skill movement.

---

# Player Input

The LocalScript is responsible only for player interaction.

Its responsibilities are:

* Detect mouse clicks
* Perform world raycasts
* Generate click visual effects
* Send movement requests
* Disable movement while combat is active

Separating player input from navigation keeps the project modular and easier to maintain.

---

# Combat Integration

The project already contains the first layer required for a tactical combat system.

When combat begins:

* Character movement is cancelled.
* New movement requests are ignored.
* Movement becomes available again after combat ends.

The next planned step is implementing Action Point (AP) consumption based on movement distance.

---

# Technologies

* Roblox Studio
* Luau
* PathfindingService
* RunService
* TweenService
* ContextActionService
* UserInputService
* Raycasting
* RemoteEvents

---

# Future Improvements

* Action Point system
* Turn manager
* Grid visualization
* Enemy AI
* Skill casting
* Multiplayer validation
* Path preview
* Movement cost visualization

---

# Author

Developed as a personal study project focused on software architecture, modular gameplay systems and tactical RPG mechanics in Roblox.
