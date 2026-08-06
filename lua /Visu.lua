
local Visu = {
    _VERSION = "2.0",
    _DESCRIPTION = "Framework visuel tout-en-un avec particules, débogage et utilitaires",
    _CONFIG = {}
}

local cache_vector = {} 
local active_animations = {}                  
local events_registry = {
    onVrConnected = nil,
    onVrDisconnected = nil
}

local particles_system = {
    particles = {},
    max_particles = 1000,
    gravity = {x=0, y=9.81},
    active = true
}

local debug_mode = false
local debug_stats = {
    fps = 0,
    particle_count = 0,
    animation_count = 0,
    light_count = 0
}

local MathUtils = {
    PI = math.pi,
    DEG2RAD = math.pi / 180,
    RAD2DEG = 180 / math.pi
}

function MathUtils.lerp(a, b, t)
    return a + (b - a) * math.max(0, math.min(1, t))
end

function MathUtils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function MathUtils.randomRange(min, max)
    return min + math.random() * (max - min)
end

function MathUtils.distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

Visu.Math = MathUtils


local SHADER_CODE = [[
    extern vec2 u_resolution;
    extern float u_bloom_intensity;
    extern float u_vignette_darkness;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 base_pixel = Texel(texture, texture_coords);
        
        float brightness = dot(base_pixel.rgb, vec3(0.2126, 0.7152, 0.0722));
        vec3 bloom = vec3(0.0);
        if (brightness > 0.65) {
            bloom = base_pixel.rgb * u_bloom_intensity;
        }
        
        vec2 uv = screen_coords / u_resolution;
        uv *=  1.0 - uv.yx;
        float vig = uv.x * uv.y * 15.0;
        vig = pow(vig, u_vignette_darkness);
        
        return vec4((base_pixel.rgb + bloom) * vig, base_pixel.a) * color;
    }
]]

local compiledShader = nil

local Light = {}
Light.__index = Light
Visu.Light = Light

function Light.new(x, y, z, r, g, b, power)
    local self = setmetatable({}, Light)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.r = r or 1.0
    self.g = g or 1.0
    self.b = b or 1.0
    self.power = power or 10.0
    return self
end

function Light:setPosition(x, y, z) self.x, self.y, self.z = x, y, z end
function Light:setPower(power) self.power = power end

local CameraVR = {}
CameraVR.__index = CameraVR
Visu.Camera = CameraVR

function CameraVR.new(ipd)
    local self = setmetatable({}, CameraVR)
    self.x, self.y, self.z = 0, 0, 0
    self.ipd = ipd or 0.064 
    return self
end

function CameraVR:updatePose(x, y, z) self.x, self.y, self.z = x, y, z end

function CameraVR:getEyePosition(eye)
    local halfIpd = self.ipd / 2
    cache_vector.x = self.x + (eye == "left" and -halfIpd or halfIpd)
    cache_vector.y = self.y
    cache_vector.z = self.z
    return cache_vector 
end

function Visu.startAnimation(name, func)
    active_animations[name] = coroutine.create(func)
end

function Visu.updateAnimations()
    for name, co in pairs(active_animations) do
        if coroutine.status(co) == "dead" then active_animations[name] = nil
        else
            local success, err = coroutine.resume(co)
            if not success then error("[Visu.lua] Erreur animation '"..name.."': "..tostring(err), 2) end
        end
    end
    debug_stats.animation_count = table_length(active_animations)
end

local function createParticle(x, y, vx, vy, life, color, size)
    return {
        x = x, y = y,
        vx = vx, vy = vy,
        life = life,
        max_life = life,
        color = color or {1, 1, 1, 1},
        size = size or 5
    }
end

function Visu.emitParticles(x, y, count, config)
    config = config or {}
    local speed = config.speed or 100
    local spread = config.spread or 360
    local life = config.life or 2
    local color = config.color or {1, 1, 1, 1}
    local size = config.size or 5
    
    for i = 1, math.min(count, particles_system.max_particles - #particles_system.particles) do
        local angle = math.random() * spread * MathUtils.DEG2RAD
        local velocity = MathUtils.randomRange(speed * 0.5, speed)
        local vx = math.cos(angle) * velocity
        local vy = math.sin(angle) * velocity
        table.insert(particles_system.particles, createParticle(x, y, vx, vy, life, color, size))
    end
    debug_stats.particle_count = #particles_system.particles
end

function Visu.updateParticles(dt)
    if not particles_system.active then return end
    
    local to_remove = {}
    for i, p in ipairs(particles_system.particles) do
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + particles_system.gravity.y * dt
        p.life = p.life - dt
        
        if p.life <= 0 then
            table.insert(to_remove, i)
        end
    end
    
    for i = #to_remove, 1, -1 do
        table.remove(particles_system.particles, to_remove[i])
    end
    debug_stats.particle_count = #particles_system.particles
end

function Visu.drawParticles()
    for _, p in ipairs(particles_system.particles) do
        local alpha = p.life / p.max_life
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.color[4] * alpha)
        love.graphics.circle("fill", p.x, p.y, p.size * alpha)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Visu.setParticleGravity(x, y)
    particles_system.gravity.x = x or 0
    particles_system.gravity.y = y or 9.81
end

function Visu.clearParticles()
    particles_system.particles = {}
    debug_stats.particle_count = 0
end

function Visu.toggleDebug()
    debug_mode = not debug_mode
    print("[Visu.lua] Mode débogage: " .. (debug_mode and "ON" or "OFF"))
end

function Visu.isDebugMode()
    return debug_mode
end

function Visu.drawDebugInfo()
    if not debug_mode then return end
    
    local info = string.format(
        "Visu.lua v%s\nFPS: %d\nParticules: %d\nAnimations: %d\nLumières: %d",
        Visu._VERSION,
        debug_stats.fps,
        debug_stats.particle_count,
        debug_stats.animation_count,
        debug_stats.light_count
    )
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 10, 10, 200, 100)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print(info, 15, 15)
    love.graphics.setColor(1, 1, 1, 1)
end

function Visu.updateFPS(dt)
    if dt and dt > 0 then
        debug_stats.fps = math.floor(1 / dt)
    end
end

function table_length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function Visu.on(eventName, callback)
    if events_registry[eventName] ~= nil then events_registry[eventName] = callback
    else error("[Visu.lua] L'événement '" .. eventName .. "' n'existe pas.", 2) end
end

local function triggerEvent(eventName, ...)
    if events_registry[eventName] then events_registry[eventName](...) end
end

function Visu.configure(key, value)
    Visu._CONFIG[key] = value
    print("[Visu.lua] Configuration: " .. key .. " = " .. tostring(value))
end

function Visu.getConfig(key)
    return Visu._CONFIG[key]
end

function Visu.resetConfig()
    Visu._CONFIG = {}
    print("[Visu.lua] Configuration réinitialisée")
end

local sprite_batch = {}

function Visu.createSpriteBatch(texture, max_sprites)
    local batch = love.graphics.newSpriteBatch(texture, max_sprites or 100)
    table.insert(sprite_batch, batch)
    return batch
end

function Visu.clearSpriteBatches()
    for _, batch in ipairs(sprite_batch) do
        batch:clear()
    end
end

function Visu.help()
    print([[
=== Visu.lua v]] .. Visu._VERSION .. [[ ===
Bibliothèque graphique complète pour Lua/LÖVE

FONCTIONNALITÉS:
- Post-processing (Bloom, Vignette)
- Support VR stéréoscopique
- Système de particules
- Animations par coroutines
- Outils de débogage visuel
- Utilitaires mathématiques
- Gestion de configuration

MODULES PRINCIPAUX:
  Visu.Math          - Fonctions mathématiques (lerp, clamp, distance...)
  Visu.Light         - Création de sources lumineuses
  Visu.Camera        - Caméra VR avec positionnement stéréo
  Visu.emitParticles - Émettre des particules
  Visu.drawDebugInfo - Afficher les stats en temps réel

COMMANDES UTILES:
  Visu.init(love, config)      - Initialiser le moteur
  Visu.start()                 - Activer les shaders
  Visu.stop()                  - Désactiver les shaders
  Visu.toggleDebug()           - Activer/désactiver le mode débogage
  Visu.configure(key, value)   - Définir une configuration
  Visu.help()                  - Afficher cette aide

EXEMPLE RAPIDE:
  function love.load()
      Visu.init(love, {width=800, height=600})
  end
  
  function love.update(dt)
      Visu.updateFPS(dt)
      Visu.updateAnimations()
      Visu.updateParticles(dt)
  end
  
  function love.draw()
      Visu.start()
      -- Votre rendu ici
      Visu.drawParticles()
      Visu.drawDebugInfo()
      Visu.stop()
  end
]])
end

function Visu.init(moteurGraphique, config)
    print("[Visu.lua] Initialisation du moteur visuel v" .. Visu._VERSION)
    Visu._CONFIG = config or {}
    if moteurGraphique and moteurGraphique.graphics and moteurGraphique.graphics.newShader then
        compiledShader = moteurGraphique.graphics.newShader(SHADER_CODE)
        compiledShader:send("u_resolution", {config.width or 1920, config.height or 1080})
        compiledShader:send("u_bloom_intensity", config.bloom_intensity or 1.5)
        compiledShader:send("u_vignette_darkness", config.vignette_darkness or 0.5)
    end
end

function Visu.start() if compiledShader then love.graphics.setShader(compiledShader) end end
function Visu.stop() love.graphics.setShader() end

return Visu
