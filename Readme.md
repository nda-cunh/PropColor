# 🎨 PropColor.vim

An ultra-fast **Vim9script** plugin to visualize and modify your colors (Hex, 0x, RGB/RGBA) in real-time, without slowing down your editor. 

Unlike older syntax-based plugins, **PropColor** leverages Vim 9's *Text Properties*, ensuring perfect fluidity even on large files.

<img width="818" height="632" alt="image" src="https://github.com/user-attachments/assets/963cbdf9-37fe-417b-9a11-b1e16d4952cf" />

And with color changing:

<img width="900" height="512" alt="image" src="https://github.com/user-attachments/assets/463b5edb-38d9-45da-9266-c0da49f2a5fd" />

---

## ✨ Features

* 🚀 **Raw Performance**: Written entirely in Vim9script with asynchronous rendering by chunks.
* 🌈 **Multi-format**: Supports `#RRGGBB`, `0xRRGGBB`, `rgb(...)` and `rgba(...)`.
* 🖌️ **Customizable Styles**: Display a bullet indicator (●), color the text, or both.
* 🛠️ **Color Picker**: Direct integration with `zenity` to modify your colors graphically.
* 🔄 **Smart Update**: Updates instantly as you type thanks to buffer `listeners`.

---

## ⚙️ Configuration

You can choose how colors are displayed by setting `g:prop_colors_style` in your `vimrc`:

| Value | Description |
| :--- | :--- |
| `'both'` | (Default) Displays the ● icon AND colors the text |
| `'icon'` | Displays only the ● icon before the color |
| `'text'` | Colors only the color hex/code text |
| `'none'` | Disables display |

**Example:**
```vim
g:prop_colors_style = 'icon'
```

### Add Custom Styles
```vim
# Example: Support for Vec4{X: 1.0, Y: 0.5, Z: 0.0, W: 1.0} format
g:prop_colors_custom = [
    {
        pattern: '\vVec4\{X:\s*([0-9.]+),\s*Y:\s*([0-9.]+),\s*Z:\s*([0-9.]+)(,\s*W:\s*[0-9.]+)?\}',
        extract: (m) => printf("#%02x%02x%02x%02x",
            float2nr(str2float(m[1]) * 255), float2nr(str2float(m[2]) * 255), float2nr(str2float(m[3]) * 255), float2nr(str2float(m[4]) * 255)
        ),
        format: (r, g, b, a) => printf("Vec4{X: %.1f, Y: %.1f, Z: %.1f, W: %.1f}", r / 255.0, g / 255.0, b / 255.0, a / 255.0),
        filetypes: ['c', 'cpp']
    },
]
```

### Disable a Style

Actually i provide: 'hex', 'hexAlpha, 'rgb' and 'rgba' styles by default, but you can disable any of them:

```vim
g:prop_colors_disable = ['rgb', 'rgba']
```

---

## ⌨️ Commands

| Command | Action |
| :--- | :--- |
| `:PropColorRefresh` | Forces a full scan of the current buffer to refresh colors. |
| `:PropColorChange` | Opens the color picker (Zenity) to modify the color under the cursor. |

---

## 📋 Prerequisites

* **Vim 9.0+** (compiled with `+textprop` support).
* **Zenity** (optional, only for the `:PropColorChange` command).
