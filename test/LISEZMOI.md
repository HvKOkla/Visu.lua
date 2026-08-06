# Test Visu.lua avec Love2D

Ce dossier contient un exemple complet pour tester la bibliothèque **Visu.lua** avec le framework Love2D.

## Structure du dossier

```
test/
├── main.lua      # Script principal Love2D (point d'entrée)
└── Visu.lua      # Bibliothèque graphique Visu.lua
```

## Comment lancer le test

### Option 1: Avec l'exécutable Love2D
```bash
love /workspace/test/
```

### Option 2: En copiant dans votre projet Love2D
Copiez simplement les deux fichiers (`main.lua` et `Visu.lua`) dans votre projet Love2D existant.

## Contrôles du jeu de test

| Touche | Action |
|--------|--------|
| **Z / ↑** | Déplacer vers le haut |
| **S / ↓** | Déplacer vers le bas |
| **Q / ←** | Déplacer vers la gauche |
| **D / →** | Déplacer vers la droite |
| **Espace** | Émettre des particules |
| **F1** | Activer/désactiver le mode debug |
| **Échap** | Quitter le jeu |

## Fonctionnalités démontrées

1. **Post-processing** : Effets Bloom et Vignette via shaders
2. **Système de particules** : Émission avec gravité configurable
3. **Animations par coroutines** : Exemple d'animation "pulse"
4. **Mode debug** : Affichage des FPS, nombre de particules, etc.
5. **Utilitaires mathématiques** : Via `Visu.Math`

## Architecture actuelle de Visu.lua

La bibliothèque est organisée en modules :

- **Visu.Math** : Fonctions utilitaires (lerp, clamp, distance, randomRange)
- **Visu.Light** : Sources lumineuses avec position 3D et couleur
- **Visu.Camera** : Caméra VR stéréoscopique
- **Système de particules** : Gestion complète avec gravité et cycle de vie
- **Gestion d'animations** : Système basé sur des coroutines
- **Debug** : Stats en temps réel et toggle
- **Configuration** : Système clé/valeur flexible
- **Shaders** : Post-processing (Bloom + Vignette)

## Personnalisation

Vous pouvez modifier les paramètres dans `love.load()` :

```lua
Visu.init(love, {
    width = 800,
    height = 600,
    bloom_intensity = 1.5,      -- Intensité du bloom
    vignette_darkness = 0.5     -- Intensité de la vignette
})
```

Et ajuster les particules :

```lua
Visu.emitParticles(x, y, count, {
    speed = 200,    -- Vitesse des particules
    spread = 360,   // Angle de dispersion (degrés)
    life = 1.5,     // Durée de vie (secondes)
    color = {1, 0.5, 0, 1},  // Couleur RGBA
    size = 8        // Taille initiale
})
```

## Intégration dans votre projet

Pour utiliser Visu.lua dans votre propre projet :

1. Copiez `Visu.lua` dans votre dossier de projet
2. Dans `main.lua`, ajoutez au début :
   ```lua
   local Visu = require("Visu")
   ```
3. Initialisez dans `love.load()` :
   ```lua
   function love.load()
       Visu.init(love, {width = 800, height = 600})
   end
   ```
4. Mettez à jour dans `love.update(dt)` :
   ```lua
   function love.update(dt)
       Visu.updateFPS(dt)
       Visu.updateAnimations()
       Visu.updateParticles(dt)
   end
   ```
5. Dessinez dans `love.draw()` :
   ```lua
   function love.draw()
       Visu.start()
       -- Votre rendu ici
       Visu.drawParticles()
       Visu.drawDebugInfo()
       Visu.stop()
   end
   ```

Bon développement ! 🎮
