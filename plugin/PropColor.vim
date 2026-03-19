vim9script noclear

if exists('g:loaded_PropColor')
	finish
endif

g:loaded_PropColor = 1

import autoload '../autoload/PropColor/PropColor.vim' as PropColor

g:prop_colors_style = get(g:, 'prop_colors_style', 'both')

def g:MixChangeColor(lnum: number, col: number)
	PropColor.MixChangeColor(lnum, col)
enddef

command! -nargs=0 PropColorRefresh		call PropColor.RefreshAllColors()
command! -nargs=0 PropColorChange		call g:MixChangeColor(line('.'), col('.'))

augroup SupraColors
    autocmd!
	autocmd User SupraMenuLoaded PropColor.InitMenuColor()
    autocmd BufReadPost * PropColor.InitColorListener()
augroup END
