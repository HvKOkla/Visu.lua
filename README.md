# Visu.lua v2.0

A lightweight, high-performance graphics pipeline for Lua games and VR applications.

## Key Features

- **Zero-Allocation System**: Runs at 90+ FPS without garbage collection stutter
- **Post-Processing Pipeline**: Built-in Bloom and cinematic vignette shaders
- **Particle System**: Integrated particle emitter with physics
- **Math Utilities**: Lerp, clamp, random range, distance calculations
- **Debug Tools**: FPS counter, visual debugging overlay
- **VR Optimized**: Stereoscopic rendering with IPD support

## Installation

**Standard Lua:**
```bash
luarocks install visu
```

**LuaJIT (Recommended for performance):**
```lua
local Visu = require("jit.Visu")
```

## Quick Start

```lua
local Visu = require("Visu")

Visu.init()
Visu.toggleDebug()

-- Emit particles
Visu.emitParticles(400, 300, 50, {
    color = {1, 0.5, 0},
    lifetime = 2.0,
    size = 5
})

-- Use math utilities
local pos = Visu.Math.lerp(0, 100, 0.5)

-- Show help
Visu.help()
```

## License

MIT License - See `LICENSE` for details.
