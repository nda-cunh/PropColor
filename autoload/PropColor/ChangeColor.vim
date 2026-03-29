vim9script

import autoload './Utils.vim' as Utils

export def MixChangeColor(lnum: number, col: number)
    const line_str = getline(lnum)
    var last_found = 0
    var matched_extractor: dict<any> = {}
    var res: list<any> = []

    const combined_pattern = Utils.GetCombinedPattern()
    while true
        var match_res = matchstrpos(line_str, combined_pattern, last_found)
        if match_res[1] == -1 | break | endif
        
        if (col >= match_res[1]) && (col <= match_res[2])
            res = match_res # [texte, start, end]
            for ext in Utils.GetAllExtractors()
                if res[0] =~ ext.pattern
                    matched_extractor = ext
                    break
                endif
            endfor
            break
        endif
        last_found = match_res[2]
    endwhile

    if empty(matched_extractor) | return | endif

    const current_hex = matched_extractor.extract(matchlist(res[0], matched_extractor.pattern))
	echom "Current color: " .. current_hex
    
    var new_color = system('zenity --color-selection --color=' .. current_hex)
    if v:shell_error != 0 || empty(new_color) | return | endif
    
	# test if zenity return rgb or rgba value
	# TODO use other method like yad
	var r: number
	var g: number
	var b: number
	var a: number = 255
	if new_color =~? '^rgba'
		var rgb_list = matchlist(new_color, 'rgba(\(\d\+\),\(\d\+\),\(\d\+\),\s*\([0-9.]\+\))')
		if empty(rgb_list) | return | endif
		r = str2nr(rgb_list[1])
		g = str2nr(rgb_list[2])
		b = str2nr(rgb_list[3])
		a = float2nr(str2float(rgb_list[4]) * 255)
	else
		var rgb_list = matchlist(new_color, 'rgb(\(\d\+\),\(\d\+\),\(\d\+\))')
		if empty(rgb_list) | return | endif
		r = str2nr(rgb_list[1])
		g = str2nr(rgb_list[2])
		b = str2nr(rgb_list[3])
	endif

    const replacement = matched_extractor.format(r, g, b, a)

	if !empty(replacement)
        const prefix = (res[1] > 0 ? line_str[: res[1] - 1] : "")
        const suffix = line_str[res[2] :]
        setline(lnum, prefix .. replacement .. suffix)
    endif
enddef

