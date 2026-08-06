-- main.lua - Exemple d'utilisation de Visu.lua avec Love2D
-- Copiez ce fichier dans un dossier Love2D avec Visu.lua

local Visu = require("Visu")

local player = { x = 400, y = 300, vx = 0, vy = 0 }
local keys = {}

function love.load()
    love.window.setTitle("Test Visu.lua")
    love.window.setMode(800, 600, {resizable = true})
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

    -- Initialiser Visu avec configuration
    Visu.init(love, {
        width = 800,
        height = 600,
        bloom_intensity = 1.5,
        vignette_darkness = 0.5
    })

    -- Configurer la gravité des particules
    Visu.setParticleGravity(0, 9.81 * 50)

    -- Créer une animation de test
    Visu.startAnimation("pulse", function()
        local t = 0
        while true do
            t = t + coroutine.yield()
            local scale = 1 + math.sin(t * 3) * 0.1
            -- Vous pouvez utiliser cette valeur pour animer vos objets
            coroutine.yield()
        end
    end)

    print("=== Test Visu.lua ===")
    print("Contrôles:")
    print("  Z/Q/S/D ou Flèches: Déplacer le joueur")
    print("  Espace: Émettre des particules")
    print("  F1: Activer/désactiver le debug")
    print("  Échap: Quitter")
end

function love.keypressed(key)
    keys[key] = true

    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        Visu.toggleDebug()
    elseif key == " " then
        -- Émettre des particules à la position du joueur
        Visu.emitParticles(player.x, player.y, 50, {
            speed = 200,
            spread = 360,
            life = 1.5,
            color = {1, 0.5, 0, 1},
            size = 8
        })
    end
end

function love.keyreleased(key)
    keys[key] = false
end

function love.update(dt)
    -- Mettre à jour les FPS pour le debug
    Visu.updateFPS(dt)

    -- Mettre à jour les animations
    Visu.updateAnimations()

    -- Mettre à jour les particules
    Visu.updateParticles(dt)

    -- Déplacement du joueur
    local speed = 300
    player.vx = 0
    player.vy = 0

    if keys["z"] or keys["up"] then player.vy = -speed end
    if keys["s"] or keys["down"] then player.vy = speed end
    if keys["q"] or keys["left"] then player.vx = -speed end
    if keys["d"] or keys["right"] then player.vx = speed end

    player.x = player.x + player.vx * dt
    player.y = player.y + player.vy * dt

    -- Limites de l'écran
    player.x = math.max(20, math.min(780, player.x))
    player.y = math.max(20, math.min(580, player.y))

    -- Émettre des particules en mouvement
    if player.vx ~= 0 or player.vy ~= 0 then
        Visu.emitParticles(player.x, player.y, 2, {
            speed = 50,
            spread = 180,
            life = 0.5,
            color = {0.5, 0.8, 1, 1},
            size = 4
        })
    end
end

function love.draw()
    -- Activer les effets post-processing
    Visu.start()

    -- Dessiner le joueur
    love.graphics.setColor(0.2, 0.8, 1, 1)
    love.graphics.circle("fill", player.x, player.y, 20)

    -- Dessiner une bordure
    love.graphics.setColor(0.3, 0.3, 0.5, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 10, 10, 780, 580)
    love.graphics.setLineWidth(1)

    -- Dessiner les particules
    Visu.drawParticles()

    -- Afficher les infos de debug
    Visu.drawDebugInfo()

    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("ZQSD/Flèches: Bouger | Espace: Particules | F1: Debug", 10, 580)

    -- Désactiver les effets post-processing
    Visu.stop()
end
