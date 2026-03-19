vim9script noclear

if exists('g:loaded_PropColor')
	finish
endif

g:loaded_PropColor = 1

import autoload '../autoload/PropColor/PropColor.vim' as PropColor

const style = get(g:, 'supravim_colors_style', 'both')
au User SupraMenuLoaded PropColor.InitMenuColor()

def g:MixChangeColor(lnum: number, col: number)
	PropColor.MixChangeColor(lnum, col)
enddef

augroup SupraColors
    autocmd!
    autocmd BufReadPost * PropColor.InitColorListener()
augroup END
