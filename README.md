# Visu.lua v1.1.0
Un framework de post-processing et de rendu réaliste unifié pour Lua

**Visu.lua** est un pipeline graphique léger et performant, conçu pour orchestrer l'intégralité des effets visuels avancés et de la réalité virtuelle dans les moteurs de jeu configurés pour Lua. Développé au sein d'une architecture fichier unique et optimisé pour le maintien de framerates critiques (VR Ready), il intègre des shaders de post-processing cinématographiques, une architecture d'éclairage dynamique orientée objet et un gestionnaire d'animations asynchrones ultra-efficace.

 Caractéristique Clé : Système Zero-Allocation
Conçu spécifiquement pour la réalité virtuelle, **Visu.lua** s'exécute à plus de 90 FPS constants sans générer de déchets en mémoire. Grâce à un système de cache vectoriel interne statique, le framework évite de surcharger le *Garbage Collector* de Lua, éliminant ainsi tout risque de micro-saccades (stuttering) en jeu.

---

## ✨ Fonctionnalités Majeures

### Rendu & Post-Processing
* **Pipeline de Post-Processing :** Injection automatisée de Shaders GLSL embarqués gérant une lueur matérielle réaliste (*Bloom*) par extraction de luminance et un effet de *vignettage cinématographique* dynamique.
* **Architecture Orientée Objet (POO) :** Instanciation et manipulation fluide de composants physiques à chaud via métatables (`Visu.Light` et `Visu.Camera`).
* **Optimisation Stéréoscopique VR :** Calcul en temps réel des matrices oculaires en fonction de l'Écart Interpupillaire (IPD) fourni par le matériel.
* **Moteur d'Animations par Coroutines :** Création de transitions temporelles complexes (variations météo, lumières vacillantes) par le biais de routines asynchrones non bloquantes.
* **Registre d'Événements (Callbacks) :** Système d'écoute événementiel découplé pour surveiller l'état du moteur et du matériel (ex: connexion/déconnexion d'un périphérique VR).

### Nouvelles Fonctionnalités (v1.1.0)

#### Utilitaires Mathématiques (`Visu.Math`)
* `lerp(a, b, t)` - Interpolation linéaire pour animations fluides
* `clamp(value, min, max)` - Plafonnement de valeurs
* `randomRange(min, max)` - Génération de nombres aléatoires dans une plage
* `distance(x1, y1, x2, y2)` - Calcul de distance entre deux points

#### Système de Particules Intégré
* `Visu.emitParticles(x, y, count, config)` - Émettre des particules avec configuration personnalisée
* `Visu.updateParticles(dt)` - Mettre à jour la physique des particules
* `Visu.drawParticles()` - Dessiner toutes les particules actives
* `Visu.setParticleGravity(x, y)` - Configurer la gravité globale
* `Visu.clearParticles()` - Nettoyer toutes les particules

#### Outils de Débogage Visuel
* `Visu.toggleDebug()` - Activer/désactiver le mode débogage
* `Visu.drawDebugInfo()` - Afficher FPS, compte de particules, animations actives
* `Visu.updateFPS(dt)` - Mettre à jour le compteur de frames par seconde

#### Gestion de Configuration Dynamique
* `Visu.configure(key, value)` - Définir une option de configuration
* `Visu.getConfig(key)` - Récupérer une valeur de configuration
* `Visu.resetConfig()` - Réinitialiser toute la configuration aux valeurs par défaut

#### Sprites avec Effets Avancés
* `Visu.createSpriteBatch(texture, max_sprites)` - Créer un batch de sprites optimisé
* `Visu.clearSpriteBatches()` - Nettoyer tous les batches de sprites

#### Documentation Intégrée
* `Visu.help()` - Affiche l'aide complète avec exemples d'utilisatio

##  Installation & Intégration

### Téléchargement Direct
1. Téléchargez le fichier `Visu.lua` depuis ce dépôt GitHub.
2. Placez-le à la racine ou dans le dossier des scripts de votre projet.


Déployez instantanément la bibliothèque sur votre environnement système en exécutant la commande suivante :
```bash
luarocks install visu
```

### Utilisation de Base
```lua
local Visu = require("Visu")

-- Initialisation
Visu.init()

-- Activer le débogage
Visu.toggleDebug()

-- Émettre des particules
Visu.emitParticles(400, 300, 50, {
    color = {1, 0.5, 0},
    lifetime = 2.0,
    size = 5
})

-- Utiliser les utilitaires mathématiques
local pos = Visu.Math.lerp(0, 100, 0.5) -- Retourne 50

-- Afficher l'aide complète
Visu.help()
```

---

## Performance

| Métrique | Valeur |
|----------|--------|
| Allocations mémoire | 0 (Zero-GC) |
| FPS moyens (VR) | 90+ |
| Taille du fichier | ~10 KB |
| Version actuelle | 1.1.0 |

---

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou soumettre une pull request pour améliorer Visu.lua.


## 📄 License

Distribué sous la license MIT. Voir `LICENSE` pour plus d'informations.
