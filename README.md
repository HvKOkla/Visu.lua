# Visu.lua
Un framework de post-processing et de rendu réaliste unifié pour Lua

**Visu.lua** est un pipeline graphique léger et performant, conçu pour orchestrer l'intégralité des effets visuels avancés et de la réalité virtuelle dans les moteurs de jeu configurés pour Lua. Développé au sein d'une architecture fichier unique et optimisé pour le maintien de framerates critiques (VR Ready), il intègre des shaders de post-processing cinématographiques, une architecture d'éclairage dynamique orientée objet et un gestionnaire d'animations asynchrones ultra-efficace.

 Caractéristique Clé : Système Zero-Allocation
Conçu spécifiquement pour la réalité virtuelle, **Visu.lua** s'exécute à plus de 90 FPS constants sans générer de déchets en mémoire. Grâce à un système de cache vectoriel interne statique, le framework évite de surcharger le *Garbage Collector* de Lua, éliminant ainsi tout risque de micro-saccades (stuttering) en jeu.

---

## ✨ Fonctionnalités Majeures

* **Pipeline de Post-Processing :** Injection automatisée de Shaders GLSL embarqués gérant une lueur matérielle réaliste (*Bloom*) par extraction de luminance et un effet de *vignettage cinématographique* dynamique.
* **Architecture Orientée Objet (POO) :** Instanciation et manipulation fluide de composants physiques à chaud via métatables (`Visu.Light` et `Visu.Camera`).
* **Optimisation Stéréoscopique VR :** Calcul en temps réel des matrices oculaires en fonction de l'Écart Interpupillaire (IPD) fourni par le matériel.
* **Moteur d'Animations par Coroutines :** Création de transitions temporelles complexes (variations météo, lumières vacillantes) par le biais de routines asynchrones non bloquantes.
* **Registre d'Événements (Callbacks) :** Système d'écoute événementiel découplé pour surveiller l'état du moteur et du matériel (ex: connexion/déconnexion d'un périphérique VR).


### Via LuaRocks (Recommandé)
Déployez instantanément la bibliothèque sur votre environnement système en exécutant la commande suivante :
```bash
luarocks install visu
