
                               Visu.lua 
      Moteur Unifié de Réalisme Graphique, Post-Processing & VR en Lua


local Visu = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "Framework visuel tout-en-un
}

-- ----------------------------------------------------------------------------
-- 1. CONFIGURATION ET CACHE (Optimisation Mémoire)
-- ----------------------------------------------------------------------------
local cache_vector = { x = 0, y = 0, z = 0 } 
local active_animations = {}                  
local events_registry = {
    onVrConnected = nil,
    onVrDisconnected = nil
}


local SHADER_CODE = [[
    extern vec2 u_resolution;
    extern float u_bloom_intensity;
    extern float u_vignette_darkness;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 base_pixel = Texel(texture, texture_coords);
        
        -- Bloom matériel (Lueur réaliste)
        float brightness = dot(base_pixel.rgb, vec3(0.2126, 0.7152, 0.0722));
        vec3 bloom = vec3(0.0);
        if (brightness > 0.65) {
            bloom = base_pixel.rgb * u_bloom_intensity;
        }
        
        -- Vignette optique
        vec2 uv = screen_coords / u_resolution;
        uv *=  1.0 - uv.yx;
        float vig = uv.x * uv.y * 15.0;
        vig = pow(vig, u_vignette_darkness);
        
        return vec4((base_pixel.rgb + bloom) * vig, base_pixel.a) * color;
    }
]]

local compiledShader = nil

-- ----------------------------------------------------------------------------
-- 2. OBJET LUMIÈRE (Métatables / POO)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 3. OBJET CAMÉRA VR (Stéréoscopie Optimisée)
-- ----------------------------------------------------------------------------
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
    cache_vector.y = self.y
    cache_vector.z = self.z
    if eye == "left" then cache_vector.x = self.x - halfIpd
    else cache_vector.x = self.x + halfIpd end
    return cache_vector 
end

-- ----------------------------------------------------------------------------
-- 4. SYSTEME DE COROUTINES (Animations / Transitions)
-- ----------------------------------------------------------------------------
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
end

-- ----------------------------------------------------------------------------
-- 5. GESTION DES ÉVÉNEMENTS (Callbacks)
-- ----------------------------------------------------------------------------
function Visu.on(eventName, callback)
    if events_registry[eventName] ~= nil then events_registry[eventName] = callback
    else error("[Visu.lua] L'événement '" .. eventName .. "' n'existe pas.", 2) end
end

local function triggerEvent(eventName, ...)
    if events_registry[eventName] then events_registry[eventName](...) end
end

-- ----------------------------------------------------------------------------
-- 6. INTERFACE DE RENDU PUBLIC
-- ----------------------------------------------------------------------------
function Visu.init(moteurGraphique, config)
    print("[Visu.lua] Initialisation du moteur visuel v" .. Visu._VERSION)
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
