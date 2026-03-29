vim9script

import autoload './Utils.vim' as Utils

export def InitMenuColor()
	call SupraMenu#Register(MenuColor)
enddef

#################
# Menu Function #
#################
def MenuColor(ctx: dict<any>): dict<any>
    const line_str = getline(ctx.line)
    const col = ctx.col
    
    var last_found = 0
    var found_color = false

	var pattern = Utils.GetCombinedPattern()
    while true
        var res = matchstrpos(line_str, pattern, last_found)
        if res[1] == -1 | break | endif
        
        if (col >= res[1]) && (col <= res[2])
            found_color = true
            break
        endif
        last_found = res[2]
    endwhile

    if !found_color
        return {}
    endif

    return {
        priority: 0,
        rows: [
            {
                label: 'Change Color',
                cmd: $':call g:MixChangeColor({ctx.line}, {ctx.col})<cr>',
                icon: '󰏘',
                type: 'n'
            }
        ]
    }
enddef
