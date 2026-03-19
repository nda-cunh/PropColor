vim9script

if !exists('*supraconfig#RegisterMany')
	finish
endif

supraconfig#RegisterGroup('PropColor', 'Settings for PropColor plugin')

import autoload '../autoload/PropColor/PropColor.vim' as PropColor

supraconfig#Register(
	{
		id: 'PropColor/type',
		type: 'string',
		default: 'both',
		lore: 'can be "none" "icon", "text" or "both". Whether to show the color as an icon, text highlight or both',
		spawn: (v) => {
			g:supravim_colors_style = v
		},
		handler: (v) => {
			g:supravim_colors_style = v
			PropColor.RefreshAllColors()
		}
	},
)
