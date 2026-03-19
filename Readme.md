# 🎨 PropColor.vim

Un plugin **Vim9script** ultra-rapide pour visualiser et modifier vos couleurs (Hex, 0x, RGB/RGBA) en temps réel, sans ralentir votre éditeur. 

Contrairement aux anciens plugins basés sur la syntaxe, **PropColor** utilise les *Text Properties* de Vim 9, ce qui garantit une fluidité parfaite même sur de gros fichiers.

---

## ✨ Fonctionnalités

* 🚀 **Performance brute** : Écrit intégralement en Vim9script avec un rendu asynchrone par paquets (*chunks*).
* 🌈 **Multi-formats** : Supporte `#RRGGBB`, `0xRRGGBB`, `rgb(...)` et `rgba(...)`.
* 🖌️ **Styles personnalisables** : Affiche un indicateur (●), colore le texte, ou les deux.
* 🛠️ **Sélecteur de couleur** : Intégration directe avec `zenity` pour modifier vos couleurs graphiquement.
* 🔄 **Intelligent** : Se met à jour instantanément pendant la frappe grâce aux *listeners* de buffer.

---

## ⚙️ Configuration

Vous pouvez choisir comment les couleurs s'affichent en définissant `g:prop_colors_style` dans votre `vimrc` :

| Valeur | Description |
| :--- | :--- |
| `'both'` | (Défaut) Affiche l'icône ● ET colore le texte |
| `'icon'` | Affiche uniquement l'icône ● devant la couleur |
| `'text'` | Colore uniquement le texte de la couleur |
| `'none'` | Désactive l'affichage |

**Exemple :**
```vim
g:prop_colors_style = 'icon'
```

---

## ⌨️ Commandes

| Commande | Action |
| :--- | :--- |
| `:PropColorRefresh` | Force un scan complet du buffer actuel pour rafraîchir les couleurs. |
| `:PropColorChange` | Ouvre le sélecteur de couleur (Zenity) pour modifier la couleur sous le curseur. |

---

## 📋 Prérequis

* **Vim 9.0+** (compilé avec le support `+textprop`).
* **Zenity** (optionnel, uniquement pour la commande `:PropColorChange`).
