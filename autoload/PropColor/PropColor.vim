vim9script

const pattern = '\v(#[0-9a-fA-F]{6}|\zs0x[0-9a-fA-F]{6}\ze[^0-9a-fA-F]|rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(,\s*[0-9.]+\s*)?\))'

export def InitMenuColor()
	call SupraMenu#Register(MenuColor)
enddef

export def RefreshAllColors()
	for i in range(1, line('$'))
		ProcessSingleLine(i)
	endfor
enddef

export def InitColorListener()
	if &buftype != '' || &buflisted == false 
        return
    endif

	if get(b:, 'PropColor_Enabled', false) == false 
		listener_add('ColorListener', bufnr('%'))
        b:PropColor_Enabled = true
	endif

	const bufnr = bufnr('%')
	const total_lines = line('$')

    for lnum in range(1, total_lines)
        ProcessSingleLine(lnum, bufnr)
    endfor
	# ScanByChunks(bufnr, 1, total_lines, 500)
enddef

def ScanByChunks(buf: number, start_lnum: number, max_lnum: number, chunk_size: number)
    if !bufexists(buf) | return | endif

    var current = start_lnum
    var end_idx = min([current + chunk_size - 1, max_lnum])

    for lnum in range(current, end_idx)
        ProcessSingleLine(lnum, buf)
    endfor

    if end_idx < max_lnum
        timer_start(20, (_) => {
            ScanByChunks(buf, end_idx + 1, max_lnum, chunk_size)
        })
    endif
enddef

export def MixChangeColor(lnum: number, col: number)
    const line_str = getline(lnum)

    var start_idx = -1
    var end_idx = -1
    var txt = ""
    var last_found = 0

    while true
        var res = matchstrpos(line_str, pattern, last_found)
        if res[1] == -1 | break | endif
        
        if (col >= res[1]) && (col <= res[2])
            txt = res[0]
            start_idx = res[1]
            end_idx = res[2]
            break
        endif
        last_found = res[2]
    endwhile

    if empty(txt) | return | endif

    var zenity_input = txt
    if txt =~ '^0x' 
        zenity_input = '#' .. txt[2 :]
    elseif txt =~ '^rgb'
        var p = matchlist(txt, '\v\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)')
        zenity_input = printf("#%02x%02x%02x", str2nr(p[1]), str2nr(p[2]), str2nr(p[3]))
    endif

    var new_color = system('zenity --color-selection --color=' .. zenity_input)
    if v:shell_error != 0 || empty(new_color) | return | endif
    var rgb_list = matchlist(new_color, 'rgb(\(\d\+\),\(\d\+\),\(\d\+\))')
    if empty(rgb_list) | return | endif

    const r = str2nr(rgb_list[1])
    const g = str2nr(rgb_list[2])
    const b = str2nr(rgb_list[3])

    var replacement = ""
    if txt =~ '^#'
        replacement = printf("#%02x%02x%02x", r, g, b)
    elseif txt =~ '^0x'
        replacement = printf("0x%02x%02x%02x", r, g, b)
    elseif txt =~ '^rgba\?'
        var alpha = (txt =~ '^rgba' ? ', 1' : '') # On garde l'alpha à 1 par défaut
        replacement = printf("%s(%d, %d, %d%s)", (empty(alpha) ? 'rgb' : 'rgba'), r, g, b, alpha)
    endif

    if !empty(replacement)
        const prefix = line_str[: start_idx - 1]
        const suffix = line_str[end_idx :]
        setline(lnum, prefix .. replacement .. suffix)
    endif
enddef


#######################
#  Private Functions  #
#######################

var known_types: dict<bool> = {}
const PREFIX = "inline_color_"
const RPREFIX = '^' .. PREFIX
const COLOR_PROP_ID = 2000

def ProcessSingleLine(lnum: number, buffer: number = bufnr('%'))
    const style = get(g:, 'prop_colors_style', 'both')
    if style == 'none' | return | endif

	const current = getbufline(buffer, lnum)[0]

	if empty(current)
		return
	endif

	const to_remove = prop_list(lnum, {bufnr: buffer})->filter((_, p) => has_key(p, 'type') && p.type =~ RPREFIX)
	for p in to_remove
        silent! prop_remove({type: p.type, bufnr: buffer}, lnum)
    endfor

	if current !~ '#' && current !~ '0x' && current !~ 'rgb'
        return
    endif
    
    var last_col = 0

    while true
        var res = matchstrpos(current, pattern, last_col)
        var raw_color = res[0]
        var starts = res[1]
        var ends = res[2]

        if starts == -1 | break | endif
        
        var hex: string
		const c0 = raw_color[0]
        if c0 == '#'
            hex = raw_color
        elseif c0 == '0' && (raw_color[1] == 'x' || raw_color[1] == 'X')
			hex = '#' .. raw_color[2 :]
        else
            var parts = matchlist(raw_color, 'rgb(\s*\(\d\+\)\s*,\s*\(\d\+\)\s*,\s*\(\d\+\)\s*)')
            if !empty(parts)
                hex = printf("#%02x%02x%02x", str2nr(parts[1]), str2nr(parts[2]), str2nr(parts[3]))
            endif
        endif

        if !empty(hex)
            const col_tag = PREFIX .. hex[1 :]
            
            # --- HIGHLIGHT ---
            if !has_key(known_types, col_tag)
                if prop_type_get(col_tag) == {}
                    execute $"highlight {col_tag} guifg={hex} gui=bold"
                    prop_type_add(col_tag, {highlight: col_tag})
                endif
                known_types[col_tag] = true
            endif

            # --- PROP ADD ---
            if style == 'both' || style == 'icon'
                prop_add(lnum, starts + 1, {
                    text: "● ", 
                    type: col_tag, 
                    id: COLOR_PROP_ID, 
                    priority: 10,
					bufnr: buffer
                })
            endif
            
            if style == 'both' || style == 'text'
                prop_add(lnum, starts + 1, {
                    type: col_tag,
                    id: COLOR_PROP_ID,
                    length: ends - starts,
                    priority: 10,
					bufnr: buffer
                })
            endif
        endif

		last_col = ends
    endwhile
enddef

def ColorListener(buf: number, startline: number, endline: number, added: number, changes: list<any>)
    var last_line = line('$')
    for lnum in range(startline, endline + added - 1)
        if lnum >= 1 && lnum <= last_line
            ProcessSingleLine(lnum)
        endif
    endfor
enddef

#################
# Menu Function #
#################
def MenuColor(ctx: dict<any>): dict<any>
    const line_str = getline(ctx.line)
    const col = ctx.col
    
    var last_found = 0
    var found_color = false

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
